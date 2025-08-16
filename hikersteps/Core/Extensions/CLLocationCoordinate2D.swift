//
//  CLLocationCoordinate2D.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/08/2025.
//

import Foundation
import CoreLocation
import FirebaseFirestore

extension CLLocationCoordinate2D {
    
    /**
     Returns a Coordinate instance for the same location
     */
    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
    
    /**
     
     */
//    func fromCoordinate(_ coordinate: Coordinate) -> GeoPoint {
//        GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
//    }
}
