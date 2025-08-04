//
//  Trail.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation

/**
 A Trail represents one of the available thru-hikes that users can chose to record their hikes on. For example, the Pacific Coast Trail or Te Araroa
 */
struct Trail: Codable, Identifiable, FirestoreEncodable  {
    /**
     Unique id for the trail, typically an uppercase, human readable acronym e.g. PCT.
     
     Currently this is set as the key in a {key, value} pair attached to an adventure document.
     */
    var id: String?
        
    /**
     Description of the trail
     */
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case name = "value"
    }
}
