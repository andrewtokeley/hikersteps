//
//  User.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/08/2025.
//

import Foundation

struct User: FirestoreEncodable, Codable, Identifiable, Equatable {
    
    /**
     The unique document id in firestore and a required property for Identifiable
     
     Note this is the uid of the user
     */
    var id: String
    
    /**
     The user's uid - read-only as this is a copy of the id.
     */
    var uid: String { id }
    
    /**
     The username that the user can define that is used in URLs to point to their online jounals. e.g. istayedhere.com/*tokes*/
     */
    var username: String
    
    /**
     The name that will be displayed when other users are searching for users to follow. If this is blank the `displayName` will be the user's `userName`
     */
    var displayName: String
    
    /**
     Marks whether the user is active. When a user elects to delete their account this flag is set to false which prevents the user's data from being accessed via the api.
     */
    var isActive: Bool = true

    var isAnonymous: Bool { return uid.isEmpty }
    
    enum CodingKeys: String, CodingKey {
        case username
        case displayName
        case isActive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        
        // this will be set in the service calls
        self.id = ""
    }
    
    init(uid: String, username: String, displayName: String, isActive: Bool = true) {
        self.id = uid
        self.username = username
        self.displayName = displayName
        self.isActive = isActive
    }
    
    /**
     Sample User, used exclusively for testing.
     */
    static var sample: User {
        return User(uid: "1", username: "tokes", displayName: "Andrew Tokeley")
    }
    
    static var anonymousUser: User {
        return User(uid: "", username: "guest", displayName: "Guest User")
    }
}



