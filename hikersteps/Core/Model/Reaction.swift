//
//  SocialReaction.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation

/**
 The source type against which a comment or reaction is made.
 */
enum SourceType: String, Hashable, Codable {
    case journal
    case checkIn
    case comment
    case none
}

/**
 Reactions that can be made on something
 */
enum ReactionType: String, Codable {
    case like
    case love
    case none
}

/**
 A reaction (like, love) recorded against something (source)
 */
struct Reaction: Identifiable, Codable, FirestoreEncodable {
    let id: String = ""
    private var _source: String
    var source: SourceType {
        get {
            return SourceType(rawValue: _source) ?? .none
        }
        set {
            _source = newValue.rawValue
        }
    }
    var sourceId: String
    
    var userId: String
    var username: String
    
    private var _reaction: String
    var reaction: ReactionType {
        get {
            return ReactionType(rawValue: _reaction) ?? .none
        }
        set {
            _reaction = newValue.rawValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case _source = "source"
        case sourceId
        case userId
        case username
        case _reaction = "reaction"
    }
}

