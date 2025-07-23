//
//  Accommodation.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import FirebaseFirestore

struct LookupItem:Codable, Identifiable, Hashable {
    /**
     Unique id for the lookup
     */
    @DocumentID var id: String?
    
    /**
     Name of the lookup
     */
    var name: String?

    var imageRotation:  Int?
    var order: Double?
    var imageName: String?
    
    var sfSymbolName: String? {
        if let imageName = imageName {
            switch imageName {
            case "send": return "tent"
            case "bedtime": return "moon.stars"
            case "airline-seat-flat": return "zzz"
            case "dormitory": return "house"
            case "apartment": return "house.badge.wifi"
            case "brightness_3": return "tree"
            case "holiday-village": return "house"
            case "cabin": return "house"
            case "carpenter": return "tent"
            case "face_retouching_natural": return "face.smiling"
            default:
                return nil
            }
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "value"
        case imageRotation
        case order
        case imageName
    }
}
