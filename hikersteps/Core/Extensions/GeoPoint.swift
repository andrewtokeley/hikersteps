//
//  GeoPoint.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/08/2025.
//

import Foundation
import FirebaseFirestore

extension GeoPoint {
    func toCoordinate() -> Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
//    func fromCoordinate(_ coordinate: Coordinate) -> GeoPoint {
//        GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
//    }
}
