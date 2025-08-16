//
//  Coordinates.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 14/08/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

/**
 The default structure across the app to describe a location on a map. Conversion methods allow translation between GEOPoint (Firestore) annd CLLocationCoordinate2D (CoreLocatin).
 */
struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(latitude: Double, longitude: Double) {
        self.init(latitude, longitude)
    }
    
    static var zero: Coordinate {
        return Coordinate(0, 0)
    }
    
    // MARK: - Conversion Functions
    
    var geoPoint: GeoPoint {
        GeoPoint(latitude: latitude, longitude: longitude)
    }
    
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Sample Coordinates
    
    static var wellington: Coordinate {
        return Coordinate(latitude: -41.29, longitude: 174.7787)
    }
}
