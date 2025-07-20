//
//  Adventure.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore

/**
 A Hike represents a walk a hiker has done on one of the trails.
 */
struct Hike: Codable, Identifiable {
    @DocumentID var id: String?
    var description: String?
    var name: String
    var uid: String
    var userName: String?
    var isPublic: Bool?
    var trail: Trail?

    enum CodingKeys: String, CodingKey {
        case isPublic = "public"
        case name
        case uid
        case id
        case description
        case trail
    }
}
