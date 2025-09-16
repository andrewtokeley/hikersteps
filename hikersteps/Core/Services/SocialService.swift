//
//  CommentService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol SocialServiceProtocol {
    
    /**
     Adds a new comment to Firestore.
     
     - Parameters:
     - comment: the `Comment` object to add.
     
     - Returns: the id of the new Comment.
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func addComment(_ comment: Comment) async throws -> String
    /**
     Deletes the specified comment (and it's associated reactions) from Firestore.
     
     - Parameters:
        - comment: the `Comment` to remove.
        - batch: optional batch to add the operation to
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func deleteComment(_ comment: Comment, batch: WriteBatch?) async throws
    /**
     Deletes all the comments for the given source.
     
     - Parameters:
        - source: the type of the source (journal, entry, comment).
        - sourceId: the document id of the source.
        - batch: optional batch to add the operation to
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func deleteComments(source: SourceType, sourceId: String, batch: WriteBatch?) async throws
    /**
     Retrieves all comments for a given source (e.g. Journal, Entry, or another Comment).
     
     - Parameters:
         - source: the type of the source (journal, entry, comment).
         - sourceId: the document id of the source.
     
     - Returns: an array of `Comment` objects.
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func getComments(source: SourceType, sourceId: String) async throws -> [Comment]
    /**
     Updare the reaction count maintained on a comment
     */
    func updateReactionCount(_ comment: Comment, to: Int) async throws
    /**
     Increment or decrement the reaction count on a comment
     */
    func addIncrementReactionCount(to batch: WriteBatch, commentId: String, incrementBy: Int64) async throws
    /**
     Adds a new Reaction to Firestore.
     
     If the reaction is for a Comment, this method also increments the comment's reactionCount
     
     - Parameters:
     - reaction: the `Reaction` object to add
     
     - Returns: the id of the new Reaction
     
     - Throws: ServiceError.unauthenticatedUser` if the caller is not authenticated
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
     Deletes all the reaction from a source, and if it's a comment, reset's the reactionCount to zero.
     
     - Parameters:
     - source: the `SourceType` of the item who's reactions should be deleted
     - sourceId: the id of the source who's reactions should be deleted
     - updateReactionCount: an optional flag to determine whether comment.reactionCount should be updated
     - batch: an optional batch to add the delete actions to a batch (and don't commit)
     
     - Important:When deleting a comment via DeleteComment, it's important to set the updateReactionCount to false, otherwise the batch write will fail - you can delete a comment AND update it's reactionCount.
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func deleteReactions(source: SourceType, sourceId: String, updateReactionCount: Bool, batch: WriteBatch?) async throws
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

extension SocialServiceProtocol {
    func deleteComment(_ comment: Comment, batch: WriteBatch? = nil) async throws {
        try await deleteComment(comment, batch: batch)
    }
}

/**
 The Social service manages comments and reactions to sources across the app.
 
 Both comments and reactions can be applied to a social source. A source is defined by a type (i.e. journal, checkIn, comment) and an id.
 */
class SocialService: SocialServiceProtocol {
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
            try await addIncrementReactionCount(to: batch, commentId: reaction.sourceId, incrementBy: 1)
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
            try await addIncrementReactionCount(to: batch, commentId: reaction.sourceId, incrementBy: -1)
        }
        
        try await batch.commit()
    }
    
    func deleteReactions(source: SourceType, sourceId: String, updateReactionCount: Bool = true, batch: WriteBatch? = nil) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        // add to the batch supplied or create a new batch and commit that directly
        let useBatch = batch ?? db.batch()
        
        let reactions = try await getReactions(source: source, sourceId: sourceId)
        for reaction in reactions {
            let docRef = db.collection(FirestoreCollection.reactions).document(reaction.id)
            useBatch.deleteDocument(docRef)
        }
        
        // reset reactionCount for comment reactions
        if source == .comment {
            if updateReactionCount {
                let commentId = sourceId
                let commentDocRef = db.collection(FirestoreCollection.comments).document(commentId)
                useBatch.updateData(["reactionCount": 0], forDocument: commentDocRef)
            }
        }
        
        // if we weren't passed a batch, commit here
        if batch == nil {
            try await useBatch.commit()
        }
        
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
        guard sourceIds.count > 0 else { return [] }
        
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
    func addComment(_ comment: Comment) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let docRef = db.collection(FirestoreCollection.comments).document()
        var newComment = comment
        newComment.id = docRef.documentID
        
        try await docRef.setData(newComment.toDictionary())
        return docRef.documentID
    }
    
    func deleteComment(_ comment: Comment, batch: WriteBatch? = nil) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !comment.id.isEmpty else { throw ServiceError.missingField("Comment id") }
        
        let useBatch = batch ?? db.batch()
        
        let docRef = db.collection(FirestoreCollection.comments).document(comment.id)
        useBatch.deleteDocument(docRef)
        
        // Add any comment reaction deletes to the same batch
        try await deleteReactions(source: .comment, sourceId: comment.id, updateReactionCount: false, batch: useBatch)

        // commit the batch if there was not parent batch supplied
        if batch == nil {
            try await useBatch.commit()
        }
    }
    
    func deleteComments(source: SourceType, sourceId: String, batch: WriteBatch? = nil) async throws {
        
        let useBatch = batch ?? db.batch()
        
        let comments = try await getComments(source: source, sourceId: sourceId)
        for comment in comments {
            // add the deletes to the batch (this will also add deleting reactions to the delete batch)
            try await deleteComment(comment, batch: useBatch)
        }
        
        // commit the batch if there was not parent batch supplied
        if batch == nil {
            try await useBatch.commit()
        }
    }
    
    func getComments(source: SourceType, sourceId: String) async throws -> [Comment] {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(FirestoreCollection.comments)
            .whereField("source", isEqualTo: source.rawValue)
            .whereField("sourceId", isEqualTo: sourceId)
            .order(by: "createdDate", descending: false)
            .getDocuments()
            
        let comments = try snapshot.documents.compactMap { doc -> Comment? in
            var item = try doc.data(as: Comment.self)
            item.id = doc.documentID
            return item
        }
        return comments.sorted(by: {$0.createdDate > $1.createdDate })
    }
    
    func updateReactionCount(_ comment: Comment, to: Int) async throws {
        let commentDocRef = db.collection(FirestoreCollection.comments).document(comment.id)
        try await commentDocRef.updateData(["reactionCount": to])
    }
    
    func addIncrementReactionCount(to batch: WriteBatch, commentId: String, incrementBy: Int64) async throws {
        let commentDocRef = db.collection(FirestoreCollection.comments).document(commentId)
        batch.updateData(["reactionCount": FieldValue.increment(incrementBy)], forDocument: commentDocRef)
    }
}

extension SocialService {
    class Mock: SocialServiceProtocol {
        
        private var comments: [Comment]
        private var reactions: [Reaction]
        
        init() {
            let r1 = Reaction(uid: "abc", source: .journal, sourceId: "1", username: "Tokes", reactionType: .like)
            let r2 = Reaction(uid: "xyz", source: .journal, sourceId: "1", username: "Alice", reactionType: .love)
            let r3 = Reaction(uid: "xyz", source: .comment, sourceId: "c1", username: "Alic", reactionType: .love)
            self.reactions = [r1, r2, r3]
            
            var c1 = Comment(uid: "abc", source: .checkIn, sourceId: "1", username: "tokes", profileUrlString: "", comment: "Love this entry!", reactionCount: 1)
            c1.id = "c1"
            var c2 = Comment(uid: "abc", source: .checkIn, sourceId: "1", username: "nicolevanruler",profileUrlString: "", comment: "Let me say it again")
            c2.id = "c2"
            self.comments = [c1, c2]
        }
        
        func addReaction(_ reaction: Reaction) async throws -> String {
            var new = reaction
            let newId = UUID().uuidString
            new.id = newId
            reactions.append(new)
            return newId
        }
        
        func deleteReaction(_ reaction: Reaction) async throws {
            reactions.removeAll { $0.id == reaction.id }
        }
        
        func deleteReactions(source: SourceType, sourceId: String, updateReactionCount: Bool = true, batch: WriteBatch? = nil) async throws {
            reactions.removeAll { $0.source == source && $0.sourceId == sourceId }
        }
        
        func getReactions(source: SourceType, sourceIds: [String]) async throws -> [Reaction] {
            return reactions.filter { $0.source == source && sourceIds.contains($0.sourceId) }
        }
        
        func getReactions(source: SourceType, sourceId: String) async throws -> [Reaction] {
            reactions.filter { $0.source == source && $0.sourceId == sourceId }
        }
        
        func updateReaction(_ reaction: Reaction) async throws {
            guard let index = reactions.firstIndex(where: { $0.id == reaction.id } ) else { throw ServiceError.generalError("Can't find reaction") }
            
            // for testing we're only ever updating the type
            reactions[index].reactionType = reaction.reactionType
        }
        
        func addComment(_ comment: Comment) async throws -> String {
            var new = comment
            new.id = UUID().uuidString
            comments.append(new)
            return new.id
        }
        
        func deleteComment(_ comment: Comment, batch: WriteBatch? = nil) async throws {
            comments.removeAll { $0.id == comment.id }
        }
        
        func deleteComments(source: SourceType, sourceId: String, batch: WriteBatch? = nil) async throws {
            //
        }
        
        func getComments(source: SourceType, sourceId: String) async throws -> [Comment] {
            comments.filter { $0.source == source && $0.sourceId == sourceId }
        }
        
        func updateReactionCount(_ comment: Comment, to: Int) async throws {
            if var comment = comments.first(where: { $0.id == comment.id }) {
                comment.reactionCount = to
            }
        }
        
        func addIncrementReactionCount(to batch: WriteBatch, commentId: String, incrementBy: Int64) async throws {
        }
    }
}
