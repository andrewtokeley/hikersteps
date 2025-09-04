//
//  SocialReaction.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation
import SwiftUI

/**
 Reactions that can be made on something
 */
enum ReactionType: String, Codable, Identifiable {
    case like
    case love
    case celebrate
    case fire
    case none
    
    var id: String { return rawValue }
    
    static var all: [ReactionType] {
        return [.like, .love, .celebrate, .fire]
    }
    
    var order: Int {
        switch self {
        case .like: return 0
        case .love: return 1
        case .celebrate: return 2
        case .fire: return 3
        case .none: return 4
        }
    }
    
    var systemImageName: String {
        switch self {
        case .like: return "hand.thumbsup"
        case .love: return "heart"
        case .celebrate: return "party.popper"
        case .fire: return "flame"
        case .none: return ""
        }
    }
    
    var title: String {
        switch self {
        case .like: return "Like"
        case .love: return "Love"
        case .celebrate: return "Celebrate"
        case .fire: return "Yes!"
        case .none: return ""
        }
    }
    
    var highlightColour: Color {
        switch self {
        case .like: return .blue
        case .love: return .red
        case .celebrate: return .green
        case .fire: return .orange
        case .none: return .clear
        }
    }
    
    var systemImageNameFilled: String {
        switch self {
        case .none: return ""
        default: return systemImageName + ".fill"
        }
    }
}

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
 A reaction (like, love) recorded against something (source)
 */
struct Reaction: Identifiable, Codable, FirestoreEncodable {
    var id: String = ""
    private var _source: String = "none"
    var source: SourceType {
        get {
            return SourceType(rawValue: _source) ?? .none
        }
        set {
            _source = newValue.rawValue
        }
    }
    var sourceId: String
    
    var uid: String
    var username: String
    
    private var _reactionType: String = "none"
    var reactionType: ReactionType {
        get {
            return ReactionType(rawValue: _reactionType) ?? .none
        }
        set {
            _reactionType = newValue.rawValue
        }
    }
    
    var createdDate: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case _source = "source"
        case sourceId
        case uid
        case username
        case _reactionType = "reactionType"
        case createdDate
    }
    
    static var nilValue: Reaction {
        return Reaction(uid: "", source: .none, sourceId: "", username: "", reactionType: .none)
    }
    var isNil: Bool {
        return self.reactionType == .none
    }
    
    init(uid: String, source: SourceType, sourceId: String, username: String, reactionType: ReactionType) {
        self.sourceId = sourceId
        self.uid = uid
        self.username = username
        self.createdDate = Date()
        self.reactionType = reactionType
        self.source = source
    }
    
    /**
     Initiaiser used by firestore to rehydrate struct
     */
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._source = try container.decodeIfPresent(String.self, forKey: ._source) ?? "none"
        self.sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId) ?? ""
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self._reactionType = try container.decodeIfPresent(String.self, forKey: ._reactionType) ?? ""
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
    }
}

