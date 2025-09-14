//
//  UserSettingsService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol UserSettingsServiceProtocol {
    
    /**
     Return the settings for the authenticated user
     
     - Returns: ``UserSettings`` for the user authenticated user
     */
    func getUserSettings() async throws -> UserSettings?
    
    /**
     Updates settings
     */
    func updateUserSettings(_ settings: UserSettings) async throws
    
    /**
     Adds new settings for a user
     */
    func addUserSettings(_ settings: UserSettings) async throws -> String
    
}

/**
 The UserService gives access to a users private and public settings.
 
 Private settings (user preferences, email...) are only visible/updatable to the user themselves,
 
 Public settings (username, displayName) can be read by anyone to allow searching for friends and other users to follow.
 */
class UserSettingsService: UserSettingsServiceProtocol {
    
    private let db = Firestore.firestore()
//    private let collectionName = "user-settings"
    
//    func updateLastViewedJournal(journalId: String) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticateUser }
//    }
    
    func updateUserSettings(_ settings: UserSettings) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }
        guard uid == settings.id else { throw ServiceError.missingField("Can't update someone else's settings") }
        
        let docRef = db.collection(FirestoreCollection.userSettings).document(uid)
        try await docRef.setData(settings.toDictionary(), merge: true)
    }
    
    func addUserSettings(_ settings: UserSettings) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }

        let docRef = db.collection(FirestoreCollection.userSettings).document(uid)
        try await docRef.setData(settings.toDictionary())
        
        return docRef.documentID
    }
    
    func getUserSettings() async throws -> UserSettings? {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        let docRef = db.collection(FirestoreCollection.userSettings).document(uid)
        let document = try await docRef.getDocument()
        if document.exists {
            var settings = try document.data(as: UserSettings.self)
            settings.id = document.documentID
            return settings
        }
        return nil
    }
}

extension UserSettingsService {
    class Mock: UserSettingsServiceProtocol {
        
        private var userSettings: UserSettings
        
        init(metric: Bool = true) {
            self.userSettings = .defaultSettings(metric)
            self.userSettings.lastJournalId = "123"
        }
        func updateLastViewedJournal(journalId: String) async throws {
            
        }
        func getUserSettings() async throws -> UserSettings? {
            return userSettings
        }
        
        func updateUserSettings(_ settings: UserSettings) async throws {
            self.userSettings = settings
        }
        
        func addUserSettings(_ settings: UserSettings) async throws -> String {
            self.userSettings.id = UUID().uuidString
            self.userSettings = settings
            return UUID().uuidString
            
        }
        
    }
}
