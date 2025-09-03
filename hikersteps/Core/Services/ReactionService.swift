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
     
     - Parameters:
     - reaction: the `Reaction` object to add
     
     - Returns: the id of the new Reaction
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func addReaction(_ reaction: Reaction) async throws -> String
    
    /**
     Deletes the specified Reaction from Firestore.
     
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
    let collectionName = "reactions"
    
    func addReaction(_ reaction: Reaction) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let newDocRef = db.collection(collectionName).document()
        try await newDocRef.setData(reaction.toDictionary(), merge: false)
        return newDocRef.documentID
    }
    
    func updateReaction(_ reaction: Reaction) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !reaction.id.isEmpty else { throw ServiceError.missingDocumentID }
        
        try await db.collection(collectionName).document(reaction.id)
            .setData(reaction.toDictionary(), merge: true)
    }
    
    func deleteReaction(_ reaction: Reaction) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !reaction.id.isEmpty else { throw ServiceError.missingField("Reaction id") }
        
        let docRef = db.collection(collectionName).document(reaction.id)
        try await docRef.delete()
    }
    
    func getReactions(source: SourceType, sourceId: String) async throws -> [Reaction] {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(collectionName)
            .whereField("source", isEqualTo: source.rawValue)
            .whereField("sourceId", isEqualTo: sourceId)
            .order(by: "createdDate", descending: false)
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
        private var items: [Reaction]
        
        init(sampleData: Bool = true) {
            if sampleData {
                let r1 = Reaction(uid: "abc", source: .journal, sourceId: "1", username: "Tokes", reactionType: .like)
                let r2 = Reaction(uid: "xyz", source: .journal, sourceId: "1", username: "Alice", reactionType: .love)
                self.items = [r1, r2]
            } else {
                self.items = []
            }
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
