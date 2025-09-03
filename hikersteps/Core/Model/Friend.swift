//
//  Friend.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/08/2025.
//

import Foundation
import FirebaseFirestore

enum FriendStatus: String {
    case pending
    case approved
}

/**
 A Friend record represents one of your friends. It matches 1:1 to a User record if you need more information about them.
 */
struct Friend: Codable {
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
     The user's username - this will be the same as if you called getUser(uid) from the user collection and is a convenience to avoid having to call into the user collection
     */
    var username: String

    private var _status: String
    var status: FriendStatus {
        get {
            return FriendStatus(rawValue: _status) ?? .pending
        }
        set {
            _status = newValue.rawValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case _status = "status"
    }
    
    init(id: String, username: String, status: FriendStatus) {
        self.id = id
        self.username = username
        self._status = status.rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self._status = try container.decodeIfPresent(String.self, forKey: ._status) ?? "pending"
        
        // this will be set in the service calls and is added here to avoid optional id
        self.id = ""
    }
}


