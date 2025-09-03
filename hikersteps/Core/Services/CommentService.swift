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

protocol CommentServiceProtocol {
    
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
     Deletes the specified comment from Firestore.
     
     - Parameters:
     - comment: the `Comment` to remove.
     
     - Throws:
     - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func deleteComment(_ comment: Comment) async throws
    
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
}

/**
 The Comment service enables create/delete/retrieve operations on a Comment entity.
 
 - Important: Within Firestore, Comments are stored in the `comments` collection.
 */
class CommentService: CommentServiceProtocol {
    let db = Firestore.firestore()
    let collectionName = "comments"
    
    func addComment(_ comment: Comment) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let docRef = db.collection(collectionName).document()
        var newComment = comment
        newComment.id = docRef.documentID
        
        try await docRef.setData(newComment.toDictionary())
        return docRef.documentID
    }
    
    func deleteComment(_ comment: Comment) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard !comment.id.isEmpty else { throw ServiceError.missingField("Comment id") }
        
        let docRef = db.collection(collectionName).document(comment.id)
        try await docRef.delete()
    }
    
    func getComments(source: SourceType, sourceId: String) async throws -> [Comment] {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(collectionName)
            .whereField("source", isEqualTo: source.rawValue)
            .whereField("sourceId", isEqualTo: sourceId)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        
        let comments = try snapshot.documents.compactMap { doc -> Comment? in
            var item = try doc.data(as: Comment.self)
            item.id = doc.documentID
            return item
        }
        return comments
    }
}

extension CommentService {
    class Mock: CommentServiceProtocol {
        
        private var items: [Comment]
        
        init(sampleData: Bool = true) {
            if sampleData {
                var c1 = Comment(uid: "abc", source: .journal, sourceId: "1", username: "1", comment: "Love this entry!")
                c1.id = "c1"
                var c2 = Comment(uid: "abc", source: .journal, sourceId: "1", username: "1", comment: "Let me say it again")
                c2.id = "c2"
                self.items = [c1, c2]
            } else {
                self.items = []
            }
        }
        
        func addComment(_ comment: Comment) async throws -> String {
            var new = comment
            new.id = UUID().uuidString
            items.append(new)
            return new.id
        }
        
        func deleteComment(_ comment: Comment) async throws {
            items.removeAll { $0.id == comment.id }
        }
        
        func getComments(source: SourceType, sourceId: String) async throws -> [Comment] {
            items.filter { $0.source == source && $0.sourceId == sourceId }
        }
    }
}
