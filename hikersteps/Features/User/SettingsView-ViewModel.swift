//
//  SettingsView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Foundation
import FirebaseAuth

extension SettingsView {
    
    protocol ViewModelProtocol: ObservableObject {
        
        init(userService: UserServiceProtocol, userSettingsService: UserSettingsServiceProtocol)
        
        /**
         Returns the user's settings. If none exist default settings are added to firestore and returned
         */
        func getSettings() async throws -> UserSettings?
        
        func updateSettings(userSettings: UserSettings) async throws
        
        func getUser() async throws -> User?
        
        func updateUser(user: User) async throws
    }
    
    class ViewModel: ViewModelProtocol {
        private var userService: UserServiceProtocol
        private var userSettingsService: UserSettingsServiceProtocol
        
        @Published var statusMessage: String? = nil
        
        required init(userService: UserServiceProtocol, userSettingsService: UserSettingsServiceProtocol) {
            self.userService = userService
            self.userSettingsService = userSettingsService
        }
        
        func getUser() async throws -> User? {
            self.statusMessage = "getting..."
            let user = try await userService.getUser()
            self.statusMessage = nil
            return user
        }
        
        func updateUser(user: User) async throws {
            self.statusMessage = "updating..."
            try await userService.updateUser(user)
            self.statusMessage = nil
        }
        
        func getSettings() async throws -> UserSettings? {
            self.statusMessage = "getting..."
            var retValue: UserSettings
            if let settings = try await userSettingsService.getUserSettings() {
                retValue = settings
            } else {
                // add default settings and return these
                var settings = UserSettings.defaultSettings
                let id = try await userSettingsService.addUserSettings(UserSettings.defaultSettings)
                settings.id = id
                retValue = settings
            }
            self.statusMessage = nil
            return retValue            
        }
        
        func updateSettings(userSettings: UserSettings) async throws {
            self.statusMessage = "updating settings..."
            try await userSettingsService.updateUserSettings(userSettings)
            self.statusMessage = nil
        }
    }
}

