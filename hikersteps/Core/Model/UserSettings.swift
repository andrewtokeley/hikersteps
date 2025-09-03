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
     The unique document id in firestore and a required property for Identifiable, will be set when retrieving data from firestore
     
     The id is also the uid of the user
     */
    var id: String = ""
    
    /**
     The user's uid - read-only as this is a copy of the id.
     */
    var uid: String { id }
    
    var email: String = ""
    var lastLoggedIn: Date = Date.distantPast
    var lastJournalId: String? = ""
    var following: [User] = []
    
    private var preferredDistanceUnitSymbol:String = UnitLength.kilometers.symbol
    var preferredDistanceUnit: UnitLength {
        get {
            // can't do this because it doesn't equate to native unit
            //return UnitLength(symbol: preferredDistanceUnitSymbol)
            switch (preferredDistanceUnitSymbol) {
            case "km": return .kilometers
            case "mi": return .miles
            default: return .kilometers
            }
        }
        set { preferredDistanceUnitSymbol = newValue.symbol }
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case lastLoggedIn
        case lastJournalId
        case following
        case preferredDistanceUnitSymbol
    }
    
    init(id: String, email: String, lastLoggedIn: Date, lastJournalId: String? = nil, preferredDistanceUnitSymbol: String = UnitLength.kilometers.symbol) {
        self.id = id
        self.email = email
        self.lastLoggedIn = lastLoggedIn
        self.lastJournalId = lastJournalId
        self.preferredDistanceUnitSymbol = preferredDistanceUnitSymbol
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.lastLoggedIn = try container.decodeIfPresent(Date.self, forKey: .lastLoggedIn) ?? Date()
        self.lastJournalId = try container.decodeIfPresent(String.self, forKey: .lastJournalId) ?? ""
        self.following = try container.decodeIfPresent(Array.self, forKey: .following) ?? []
        self.preferredDistanceUnitSymbol = try container.decodeIfPresent(String.self, forKey: .preferredDistanceUnitSymbol) ?? "km"
        
    }
    
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
            preferredDistanceUnitSymbol: metric ? UnitLength.kilometers.symbol : UnitLength.miles.symbol)
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

