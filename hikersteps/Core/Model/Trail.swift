//
//  Trail.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore

/**
 A Trail represents a thru-hike that a user's Journal describes. For example, the Pacific Coast Trail or Te Araroa.
 
 - Important: all properties (apare
 */
import SwiftUI
import FirebaseFirestore

struct Trail: Identifiable, Codable, FirestoreEncodable, Hashable {
    var id: String { return key }
    var key: String = ""
    var name: String = ""
    var country: String = ""
    var countryCode: String = ""
    
    private var lengthKm: Int = 0
    var length: DistanceUnit {
        get { DistanceUnit(lengthKm, .km) }
        set { lengthKm = Int(newValue.convertTo(.km).number) }
    }
    
    private var northernTerminus_GeoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    var northernTerminus: Coordinate {
        get { northernTerminus_GeoPoint.toCoordinate() }
        set { northernTerminus_GeoPoint = newValue.geoPoint }
    }
    
    private var southernTerminus_GeoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    var southernTerminus: Coordinate {
        get { southernTerminus_GeoPoint.toCoordinate() }
        set { southernTerminus_GeoPoint = newValue.geoPoint }
    }
    
    var startLocations: [CheckInAnnotation] = []
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case country
        case countryCode
        case lengthKm
        case startLocations
    }
    
    init(key: String = "", name: String = "", country: String = "", countryCode: String = "", length: DistanceUnit = DistanceUnit.zero(.km), startLocations: [CheckInAnnotation] = [] ) {
        self.key = key
        self.name = name
        self.country = country
        self.countryCode = countryCode
        self.lengthKm = Int(length.convertTo(.km).number)
        self.startLocations = startLocations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode) ?? ""
        self.lengthKm = try container.decodeIfPresent(Int.self, forKey: .lengthKm) ?? 0
        self.startLocations = try container.decodeIfPresent(Array.self, forKey: .startLocations) ?? []
    }
    
    static var sample: Trail {
        TrailService.allTrails.first!
    }
}
