//
//  CheckIn.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct CheckIn: Codable, Identifiable, Equatable {
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        lhs.id == rhs.id
    }
    
    @DocumentID var id: String?
    var uid: String
    var locationAsGeoPoint: GeoPoint
    var location: Coordinate {
        locationAsGeoPoint.toCoordinate()
    }
    var title: String?
    var address: String?
    var accommodation: LookupItem?
    var notes: String?
    var date = Date.now
    var type: String?
    var nearestTrailMarker: Double = 0
    var distanceWalked: Int = 0
    var images: [StorageImage] = []
    var numberOfRestDays: Int = 0
    var numberOfOffTrailDays: Int = 0
    var adventureId: String?
    var customLinks: [CustomLink] = []
    var resupply: Bool? = false
    var resupplyNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case date
        case locationAsGeoPoint = "location"
        case title
        case address
        case accommodation
        case notes
        case type
        case nearestTrailMarker
        case distanceWalked
        case images
        case numberOfRestDays
        case numberOfOffTrailDays
        case adventureId
        case customLinks
        case resupply
        case resupplyNotes

    }
    
    static var newWithDefaults: CheckIn {
        return CheckIn(id: "0", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: 0, longitude: 0).toGeoPoint())
    }
    
    static func new(location: CLLocationCoordinate2D) -> CheckIn {
        var new = newWithDefaults
        new.title = "Dropped Pin"
        new.locationAsGeoPoint = Coordinate(from: location).toGeoPoint()
        return new
    }
    static var sample: CheckIn {
        return CheckIn(id: "12", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: -41.29, longitude: 174.7787).toGeoPoint(), title: "Hotel High Five", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something ", distanceWalked: 123, numberOfRestDays: 1, numberOfOffTrailDays: 2)
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from: CLLocationCoordinate2D) {
        self.init(latitude: from.latitude, longitude: from.longitude)
    }
    
    func toGeoPoint() -> GeoPoint {
        GeoPoint(latitude: latitude, longitude: longitude)
    }
    
    func toCLLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var wellington: Coordinate {
        return Coordinate(latitude: -41.29, longitude: 174.7787)
    }
}

extension GeoPoint {
    func toCoordinate() -> Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
    func fromCoordinate(_ coordinate: Coordinate) -> GeoPoint {
        GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
