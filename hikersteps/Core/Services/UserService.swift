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
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticateUser }
        
        try await db.collection(collectionName)
            .document(uid)
            .setData(user.toDictionary(), merge: true)
    }
    
    func addUser(_ user: User) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticateUser }
        guard uid == user.id else { throw ServiceError.generalError("Can't add user with different ID than current user's uid") }
        
        let docRef = db.collection(collectionName).document(uid)
        try await docRef.setData(user.toDictionary())
        return docRef.documentID
    }
    
    func getUser() async throws -> User? {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        let docRef = db.collection(collectionName).document(uid)
        let document = try await docRef.getDocument()
        if document.exists {
            var user = try document.data(as: User.self)
            user.id = document.documentID
            return user
        }
        return nil
    }
    
    func deleteUser(_ user: User) async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
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
        
        func updateUser(_ user: User) async throws {
            //
        }
        
        func addUser(_ user: User) async throws -> String {
            return "123"
        }
        
        func deleteUser(_ user: User) async throws {
            //
        }
        
        
    }
}
