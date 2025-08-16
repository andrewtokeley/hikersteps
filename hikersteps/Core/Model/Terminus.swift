//
//  Terminus.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 13/08/2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct Terminus: Codable, Equatable, FirestoreEncodable {
    var name: String
    private var locationAsGeoPoint: GeoPoint
    var location: Coordinate {
        get { locationAsGeoPoint.toCoordinate() }
        set { locationAsGeoPoint = newValue.geoPoint }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case locationAsGeoPoint = "coordinate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.locationAsGeoPoint = try container.decodeIfPresent(GeoPoint.self, forKey: .locationAsGeoPoint) ?? GeoPoint.init(latitude: 0, longitude: 0 )
    }
}
