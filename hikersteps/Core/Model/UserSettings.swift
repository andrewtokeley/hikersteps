//
//  UserSettings.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Foundation

/**
 Settings for a user. These are a combination of user defined preferences and settings that are set by the system (e.g. last logged in)
 */
struct UserSettings: FirestoreEncodable, Codable, Identifiable, Equatable {
    /**
     The unique document id in firestore and a required property for Identifiable
     
     Note this is the uid of the user
     */
    var id: String
    
    /**
     The user's uid - read-only as this is a copy of the id.
     */
    var uid: String { id }
    
    var email: String
    var lastLoggedIn: Date = Date.distantPast
    var lastJournalId: String?
    var following: [User] = []
    var preferredDistanceUnit: Unit = .km
    
    static var sample: UserSettings {
        return UserSettings(
            id: "1",
            email: "andrewtokeley@gmail.com",
            lastLoggedIn: Date(),
            lastJournalId: nil)
    }

    /**
     Returns default settings in either metric (default) or imperial
     */
    static func defaultSettings(_ metric: Bool = true) -> UserSettings {
        return UserSettings(
            id: "",
            email: "",
            lastLoggedIn: Date(),
            preferredDistanceUnit: metric ? .km : .mi)
    }
    
    /**
     Need equality checking to identify when settings are "dirty" and need saving in SettingsView. Won't automatically conform because of Date.
     */
    static func == (lhs: UserSettings, rhs: UserSettings) -> Bool {
        return lhs.id == rhs.id &&
        lhs.email == rhs.email &&
        Calendar.current.isDate(lhs.lastLoggedIn, inSameDayAs: rhs.lastLoggedIn) &&
        lhs.lastJournalId == rhs.lastJournalId &&
        lhs.following == rhs.following &&
        lhs.preferredDistanceUnit == rhs.preferredDistanceUnit
    }
}

