//
//  Accommodation.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import FirebaseFirestore

struct LookupItem:Codable, Identifiable, Hashable {
    
    static let defaultImageName = "questionmark.app"
    
    /**
     Unique id for the lookup
     */
    @DocumentID var id: String?
    
    /**
     Name of the lookup
     */
    var name: String = "Select Item"

    var imageRotation:  Int = 0
    var order: Double = 0
    
    /**
     The image for the lookup.
     
     On iOS, this image should be a SF Symbol name. Some known material icons from the original web app will converted to symbols.
     */
    var imageName: String = ""
    
    private func convertToSFSymbol(_ imageName: String) -> String? {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "value"
        case imageRotation
        case order
        case imageName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Attempt to decode each value, using a default if it's missing or null
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? ""
        self.imageName = safeConvert(self.imageName)
        self.imageRotation = try container.decodeIfPresent(Int.self, forKey: .imageRotation) ?? 0
        self.order = try container.decodeIfPresent(Double.self, forKey: .order) ?? 0
    }
    
    init(id: String, name: String, imageName: String = LookupItem.defaultImageName) {
        self.id = id
        self.name = name
        self.order = -1
        self.imageName = safeConvert(imageName)
    }
    
    init() {
        
    }
    
    
    var isNoSelection: Bool { return self.id == LookupItem.noSelectionID }
    
    static private let noSelectionID = "none"
    static func noSelection(_ imageName: String = "") -> LookupItem {
        var lookup = LookupItem()
        lookup.id = noSelectionID
        lookup.imageName = imageName
        lookup.name = "No Selection"
        lookup.order = -999
        return lookup
    }
    
    private func safeConvert(_ imageName: String) -> String {
        print("from \(imageName)...")
        // First see if this is an SFSymbolName
        if (UIImage(systemName: imageName) != nil) {
            print("to \(imageName)...")
            return imageName
            // Or maybe it's a Material Icon name we can convert
        } else if let converted = self.convertToSFSymbol(imageName) {
            print("to \(converted)...")
            return converted
            // If all else fails us leave it blank
        } else {
            print("to blank...")
            return ""
        }
    }
}
