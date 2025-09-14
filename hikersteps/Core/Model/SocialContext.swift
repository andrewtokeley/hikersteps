//
//  SocialContext.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 04/09/2025.
//

import Foundation

/**
 Requiired data to describe the context of a comment or reaction
 */
struct SocialContext {
    var uid: String {
        auth.user.uid
    }
    
    var username: String {
        auth.user.username
    }
    
    var displayName: String {
        auth.user.isActive.description
    }
    var profileUrl: URL? {
        auth.user.profileUrl
    }
    
    let source: SourceType
    let sourceId: String
    let auth: any AuthenticationManagerProtocol
    
    init(source: SourceType, sourceId: String, auth: any AuthenticationManagerProtocol) {
        self.source = source
        self.sourceId = sourceId
        self.auth = auth
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

