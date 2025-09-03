//
//  UserService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol UserServiceProtocol {
    
    /**
     Return the settings for the authenticated user
     
     - Returns: ``User`` for the authenticated user. If the user doesn't have a corresponding document the func returns nil.
     */
    func getUser() async throws -> User?
    
    func getUser(username: String) async throws -> User?
    
    func searchUsersByUsername(prefix: String) async throws -> [User]
    
    /**
     Save a user document, including any settings.
     */
    func updateUser(_ user: User) async throws
    
    /**
     Adds new a new user to the system, including their settings - typically as a result of a first log in
     */
    func addUser(_ user: User) async throws -> String
    
    /**
     Marks the user as deleted. Nothing actually gets deleted but this will prevent the user's data, including journals, being returned from the api
     */
    func deleteUser(_ user: User) async throws
}

/**
 The UserService gives access to a users private and public settings.
 
 Private settings (user preferences, email...) are only visible/updatable to the user themselves,
 
 Public settings (username, displayName) can be read by anyone to allow searching for friends and other users to follow.
 */
class UserService: UserServiceProtocol {

    private let db = Firestore.firestore()
    private let collectionName = "users"
    private let privateSubCollectionName = "private"

    func updateUser(_ user: User) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }
        
        try await db.collection(collectionName)
            .document(uid)
            .setData(user.toDictionary(), merge: true)
    }
    
    func addUser(_ user: User) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }
        guard uid == user.id else { throw ServiceError.generalError("Can't add user with different ID than current user's uid") }
        
        let docRef = db.collection(collectionName).document(uid)
        try await docRef.setData(user.toDictionary())
        return docRef.documentID
    }
    
    func getUser(username: String) async throws -> User? {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let snapshot = try await db.collection(collectionName)
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        let users = try snapshot.documents.compactMap { doc -> User? in
            var user = try doc.data(as: User.self)
            user.id = doc.documentID
            return user
        }
        return users.isEmpty ? nil : users[0]
    }
    
    func searchUsersByUsername(prefix: String) async throws -> [User] {
        guard !prefix.isEmpty else { return [] }
        
        let endPrefix = prefix + "\u{f8ff}" // Highest possible UTF-8 character
        
        let snapshot = try await db.collection(collectionName)
            .whereField("username", isGreaterThanOrEqualTo: prefix)
            .whereField("username", isLessThanOrEqualTo: endPrefix)
            .getDocuments()
        
        let users = try snapshot.documents.compactMap { doc -> User? in
            var user = try doc.data(as: User.self)
            user.id = doc.documentID
            return user
        }
        return users
    }
    
    func getUser() async throws -> User? {
        guard let authUser = Auth.auth().currentUser else {
            throw ServiceError.unauthenticatedUser
        }
        
        let docRef = db.collection(collectionName).document(authUser.uid)
        let document = try await docRef.getDocument()
        if document.exists {
            var user = try document.data(as: User.self)
            user.id = document.documentID
            user.email = authUser.email ?? ""
            return user
        }
        return nil
    }
    
    func deleteUser(_ user: User) async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        var copy = user
        copy.isActive = false
        try await self.updateUser(user)
    }
}

extension UserService {
    class Mock: UserServiceProtocol {
        func getUser() async throws -> User? {
            return User.sample
        }
        
        func getUser(username: String) async throws -> User? {
            return username == User.sample.username ? User.sample : nil
        }
        
        func updateUser(_ user: User) async throws {
            //
        }
        
        func addUser(_ user: User) async throws -> String {
            return "123"
        }
        
        func deleteUser(_ user: User) async throws {
            //
        }
        
        func searchUsersByUsername(prefix: String) async throws -> [User] {
            return []
        }
    }
}
