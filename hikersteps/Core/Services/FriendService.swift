//
//  FriendService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/08/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


protocol FriendServiceProtocol {
    func getFriends(status: FriendStatus?) async throws -> [Friend]
    func addFriend(uid: String, username: String) async throws
    func setFriendStatus(friendUid: String, status: FriendStatus) async throws
    func getFriendJournals() async throws -> [Journal]
    func deleteFriend(uidFriend: String) async throws
}

class FriendService: FriendServiceProtocol {
    private let db = Firestore.firestore()
        
    // MARK: - Get Friends (Approved Only)
    func getFriends(status: FriendStatus? = nil) async throws -> [Friend] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        let collRef = db.collection(FirestoreCollection.friends).document(uid).collection(FirestoreCollection.friends_userFriends)
        var snapshot: QuerySnapshot
        if let status = status?.rawValue {
            snapshot = try await collRef
                .whereField("status", isEqualTo: status)
                .getDocuments()
        } else {
            snapshot = try await collRef.getDocuments()
        }
            
        let friends = try snapshot.documents.compactMap { doc -> Friend? in
            var friend = try doc.data(as: Friend.self)
            friend.id = doc.documentID
            return friend
        }
        
        return friends
    }
    
    // MARK: - Add Friend (Pending)
    func addFriend(uid uidFriend: String, username: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        let ref = db.collection(FirestoreCollection.friends)
            .document(uid)
            .collection(FirestoreCollection.friends_userFriends)
            .document(uidFriend)
        
        let data = Friend(id: uidFriend, username: username, status: .pending)
        try ref.setData(from: data)
    }
    
    // MARK: - Delete Friend
    func deleteFriend(uidFriend: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        let ref = db.collection(FirestoreCollection.friends)
            .document(uid)
            .collection(FirestoreCollection.friends_userFriends)
            .document(uidFriend)
        
        try await ref.delete()
    }
    
    // MARK: - Set Friend Status
    func setFriendStatus(friendUid: String, status: FriendStatus) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        let ref = db.collection(FirestoreCollection.friends)
            .document(uid)
            .collection(FirestoreCollection.friends_userFriends)
            .document(friendUid)
        
        try await ref.updateData(["status": status.rawValue])
    }
    
    // MARK: - Get Friend Journals
    func getFriendJournals() async throws -> [Journal] {
        let friends = try await getFriends()
        let friendIds = friends.compactMap { $0.id }
        
        guard !friendIds.isEmpty else { return [] }
        
        // Break into chunks for Firestore 'in' query limit (10)
        let chunks = stride(from: 0, to: friendIds.count, by: 10).map {
            Array(friendIds[$0..<min($0 + 10, friendIds.count)])
        }
        
        var allJournals: [Journal] = []
        
        try await withThrowingTaskGroup(of: [Journal].self) { group in
            for chunk in chunks {
                group.addTask {
                    let snapshot = try await self.db.collection(FirestoreCollection.journals)
                        .whereField("uid", in: chunk)
                        .whereField("visibility", in: ["friends", "public"])
                        .getDocuments()
                    
                    return try snapshot.documents.compactMap { doc -> Journal? in
                        var journal = try doc.data(as: Journal.self)
                        journal.id = doc.documentID
                        return journal
                    }
                }
            }
            
            for try await journals in group {
                allJournals.append(contentsOf: journals)
            }
        }
        
        return allJournals
    }
}
