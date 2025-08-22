//
//  UserTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Testing
import Foundation
import UIKit
import FirebaseAuth

@testable import hikersteps

struct UserTests {
    let userSettingsService =  UserSettingsService()
    let userService = UserService()
    
    @Test func addUserSettings() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        if let _ = try await userSettingsService.getUserSettings() {
            // no need to add
            #expect(Bool(true))
        } else {
            // add some
            let settings = UserSettings.defaultSettings
            let newId = try await userSettingsService.addUserSettings(settings)
            #expect(newId == uid)
            
            if let settings = try await userSettingsService.getUserSettings() {
                #expect(settings.id == uid)
            }
        }
    }
    
    @Test func getUser() async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        if let user = try await userService.getUser() {
            #expect(user.username == "tokes")
            #expect(user.uid != "")
        }
    }

}
