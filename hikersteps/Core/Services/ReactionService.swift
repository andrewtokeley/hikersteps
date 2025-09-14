//
//  ReactionService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol ReactionServiceProtocol {
    
    /**
     Adds a new Reaction to Firestore.
     
     If the reaction is for a Comment, this method also increments the comment's reactionCount
     
     - Parameters:
     - reaction: the `Reaction` object to add
     
     - Returns: the id of the new Reaction
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func addReaction(_ reaction: Reaction) async throws -> String
    
    /**
     Deletes the specified Reaction from Firestore.
     
     If the reaction is for a Comment, this method also decrements the comment's reactionCount
     
     - Parameters:
     - reaction: the `Reaction` to remove
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func deleteReaction(_ reaction: Reaction) async throws
    
    /**
     Retrieves all reactions for a given source (e.g. Journal, CheckIn, or Comment).
     
     - Parameters:
     - source: the `SourceType` of the item reacted to
     - sourceId: the document id of the source
     
     - Returns: an array of `Reaction` objects
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func getReactions(source: SourceType, sourceId: String) async throws -> [Reaction]
    
    /**
    Retrieves all reactions for a given source (e.g. Journal, CheckIn, or Comment).
        
    - Parameters:
     - source: the `SourceType` of the reactions to return
     - sourceIds: an array of sourceIds the reactions must be contained in
        
    - Returns: an array of `Reaction` objects
     
    - Throws:
    - `ServiceError.unauthenticatedUser` if the caller is not authenticated
    */
    func getReactions(source: SourceType, sourceIds: [String]) async throws -> [Reaction]
    
    /**
     Updates the given reaction to a new reaction type
     */
    func updateReaction(_ reaction: Reaction) async throws
}

/**
 The Reaction service enables create/delete/retrieve operations on a Reaction entity.
 
 - Important: Within Firestore, Reactions are stored in the `reactions` collection.
 */
class ReactionService: ReactionServiceProtocol {
    let db = Firestore.firestore()
    
    func addReaction(_ reaction: Reaction) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let batch = db.batch()
        
        // add to reactions collection
        let newDocRef = db.collection(FirestoreCollection.reactions).document()
        if let dictionary = try? reaction.toDictionary() {
            batch.setData(dictionary, forDocument: newDocRef, merge: false)
        } else {
            throw ServiceError.generalError("Can't convert checkIn to dictionary")
        }
        
        // if a reaction to a comment, update reaction count
        if (reaction.source == .comment) {
            let commentId = reaction.sourceId
            let commentDocRef = db.collection(FirestoreCollection.comments).document(commentId)
            batch.updateData(["reactionCount": FieldValue.increment(Int64(1))], forDocument: commentDocRef)
        }
        
        try await batch.commit()
        
        return newDocRef.documentID
    }
    
    func updateReaction(_ reaction: Reaction) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !reaction.id.isEmpty else { throw ServiceError.missingDocumentID }
        
        try await db.collection(FirestoreCollection.reactions).document(reaction.id)
            .setData(reaction.toDictionary(), merge: true)
    }
    
    func deleteReaction(_ reaction: Reaction) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !reaction.id.isEmpty else { throw ServiceError.missingField("Reaction id") }
        
        let batch = db.batch()
        
        let docRef = db.collection(FirestoreCollection.reactions).document(reaction.id)
        batch.deleteDocument(docRef)
        
        if reaction.source == .comment {
            let commentId = reaction.sourceId
            let commentDocRef = db.collection(FirestoreCollection.comments).document(commentId)
            batch.updateData(["reactionCount": FieldValue.increment(Int64(-1))], forDocument: commentDocRef)
        }

        try await batch.commit()
    }
    
    func getReactions(source: SourceType, sourceId: String) async throws -> [Reaction] {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(FirestoreCollection.reactions)
            .whereField(Reaction.CodingKeys._source.rawValue, isEqualTo: source.rawValue)
            .whereField(Reaction.CodingKeys.sourceId.rawValue, isEqualTo: sourceId)
            .order(by: Reaction.CodingKeys.createdDate.rawValue, descending: false)
            .getDocuments()
        
        let reactions = try snapshot.documents.compactMap { doc -> Reaction? in
            var item = try doc.data(as: Reaction.self)
            item.id = doc.documentID
            return item
        }
        return reactions
    }
    
    func getReactions(source: SourceType, sourceIds: [String]) async throws -> [Reaction] {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(FirestoreCollection.reactions)
            .whereField(Reaction.CodingKeys._source.rawValue, isEqualTo: source.rawValue)
            .whereField(Reaction.CodingKeys.sourceId.rawValue, in: sourceIds)
            .getDocuments()
        
        let reactions = try snapshot.documents.compactMap { doc -> Reaction? in
            var item = try doc.data(as: Reaction.self)
            item.id = doc.documentID
            return item
        }
        
        return reactions
    }
}

extension ReactionService {
    class Mock: ReactionServiceProtocol {
        private var commentService = CommentService.Mock(sampleData: true)
        private var items: [Reaction]
        
        init(sampleData: [Reaction]) {
            self.items = sampleData
        }
        
        convenience init() {
            let r1 = Reaction(uid: "abc", source: .journal, sourceId: "1", username: "Tokes", reactionType: .like)
            let r2 = Reaction(uid: "xyz", source: .journal, sourceId: "1", username: "Alice", reactionType: .love)
            let r3 = Reaction(uid: "xyz", source: .comment, sourceId: "c1", username: "Alic", reactionType: .love)
            
            self.init(sampleData: [r1, r2, r3])
        }
        
        func addReaction(_ reaction: Reaction) async throws -> String {
            var new = reaction
            let newId = UUID().uuidString
            new.id = newId
            items.append(new)
            return newId
        }
        
        func deleteReaction(_ reaction: Reaction) async throws {
            items.removeAll { $0.id == reaction.id }
        }
        
        func getReactions(source: SourceType, sourceIds: [String]) async throws -> [Reaction] {
            return items.filter { $0.source == source && sourceIds.contains($0.sourceId) }
        }
        
        func getReactions(source: SourceType, sourceId: String) async throws -> [Reaction] {
            items.filter { $0.source == source && $0.sourceId == sourceId }
        }
        
        func updateReaction(_ reaction: Reaction) async throws {
            guard let index = items.firstIndex(where: { $0.id == reaction.id } ) else { throw ServiceError.generalError("Can't find reaction") }
            
            // for testing we're only ever updating the type
            items[index].reactionType = reaction.reactionType
        }
    }
}
