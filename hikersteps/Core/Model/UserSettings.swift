//
//  UserSettings.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 23/07/2025.
//

import Foundation

struct UserSettings: Codable, FirestoreEncodable  {
    var preferredDistanceUnit: Unit = .km
    
    static func sample() -> UserSettings {
        UserSettings()
    }
}
