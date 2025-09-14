//
//  FirestoreCollection.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 13/09/2025.
//

import Foundation

struct FirestoreCollection {
    static let checkIns = "check-ins"
    static let journals = "adventures"
    static let comments = "comments"
    static let friends = "friends"
    static let friends_userFriends = "userFriends" // subcollection of friends collection
    static let lookups = "lookups"
    static let lookups_keys = "keys" // subcollection of lookups
    static let mapLayers = "map-layers"
    static let reactions = "reactions"
    static let social = "social"
    static let trails = "trails"
    static let users = "users"
    static let userSettings = "user-settings"
}
