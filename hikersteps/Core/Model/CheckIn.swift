//
//  CheckIn.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct CheckIn: Codable, Identifiable, Equatable, FirestoreEncodable {
    internal var _isNilValue: Bool = false

    @DocumentID var id: String?
    
    // All properties are marked as non-optional even if they are optionally set by user. This allows us to bind directly to these properties from views (can't bind to optionals)
    var uid: String = ""
    var locationAsGeoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    var location: Coordinate {
        locationAsGeoPoint.toCoordinate()
    }
    var title: String = ""
    var address: String = ""
    var accommodation: LookupItem = LookupItem.noSelection()
    var notes: String = ""
    var date = Calendar.current.startOfDay(for: Date())
    var type: String = "day"
    var nearestTrailMarker: Double = 0
    var distanceWalked: Int = 0
    var images: [StorageImage] = []
    var numberOfRestDays: Int = 0
    var numberOfOffTrailDays: Int = 0
    var adventureId: String = ""
    var customLinks: [CustomLink] = []
    var resupply: Bool = false
    var resupplyNotes: String = ""
    
    enum CodingKeys: String, CodingKey {
        //case id
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        self.locationAsGeoPoint = try container.decodeIfPresent(GeoPoint.self, forKey: .locationAsGeoPoint) ?? GeoPoint.init(latitude: 0, longitude: 0 )
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        self.accommodation = try container.decodeIfPresent(LookupItem.self, forKey: .accommodation) ?? LookupItem.noSelection()
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        self.nearestTrailMarker = try container.decodeIfPresent(Double.self, forKey: .nearestTrailMarker) ?? 0
        self.distanceWalked = try container.decodeIfPresent(Int.self, forKey: .distanceWalked) ?? 0
        self.images = try container.decodeIfPresent(Array.self, forKey: .images) ?? []
        self.numberOfRestDays = try container.decodeIfPresent(Int.self, forKey: .numberOfRestDays) ?? 0
        self.numberOfOffTrailDays = try container.decodeIfPresent(Int.self, forKey: .numberOfOffTrailDays) ?? 0
        self.adventureId = try container.decodeIfPresent(String.self, forKey: .adventureId) ?? ""
        self.customLinks = try container.decodeIfPresent(Array.self, forKey: .customLinks) ?? []
        self.resupply = try container.decodeIfPresent(Bool.self, forKey: .resupply) ?? false
        self.resupplyNotes = try container.decodeIfPresent(String.self, forKey: .resupplyNotes) ?? ""
    
    }
        
    init(id: String = "", uid: String = "", location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0 ), title: String = "", notes: String = "", distanceWalked: Int = 0, numberOfRestDays: Int = 0, numberOfOffTrailDays: Int = 0, date: Date = Date(), images: [StorageImage] = [], accommodation: LookupItem = LookupItem.noSelection()) {
        self.id = id
        self.uid = uid
        self.locationAsGeoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
        self.title = title
        self.notes = notes
        self.distanceWalked = distanceWalked
        self.numberOfRestDays = numberOfRestDays
        self.numberOfOffTrailDays = numberOfOffTrailDays
        self.date = date
        self.images = images
        self.accommodation = accommodation
    }
    /**
     Need to override default equalify check because GeoPoints and Dates are classes and won't necessarily compare with ==
     */
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        return lhs.id == rhs.id &&
        lhs.uid == rhs.uid &&
        lhs.locationAsGeoPoint.latitude == rhs.locationAsGeoPoint.latitude &&
        lhs.locationAsGeoPoint.longitude == rhs.locationAsGeoPoint.longitude &&
        lhs.title == rhs.title &&
        lhs.address == rhs.address &&
        lhs.accommodation == rhs.accommodation &&
        lhs.notes == rhs.notes &&
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date) &&
        lhs.type == rhs.type &&
        lhs.nearestTrailMarker == rhs.nearestTrailMarker &&
        lhs.distanceWalked == rhs.distanceWalked &&
        lhs.images == rhs.images &&
        lhs.numberOfRestDays == rhs.numberOfRestDays &&
        lhs.numberOfOffTrailDays == rhs.numberOfOffTrailDays &&
        lhs.adventureId == rhs.adventureId &&
        lhs.customLinks == rhs.customLinks &&
        lhs.resupply == rhs.resupply &&
        lhs.resupplyNotes == rhs.resupplyNotes &&
        lhs._isNilValue == rhs._isNilValue
    }
    
    func toDictionary() -> [String: Any]? {
        do {
            let encoder = Firestore.Encoder()
            return try encoder.encode(self)
        } catch {
            print("Failed to encode CheckIn: \(error)")
            return nil
        }
    }
    
    static var newWithDefaults: CheckIn {
        return CheckIn()
    }
    
    static func new(location: CLLocationCoordinate2D) -> CheckIn {
        var new = newWithDefaults
        new.title = "Dropped Pin"
        new.locationAsGeoPoint = Coordinate(from: location).toGeoPoint()
        return new
    }
    
    static func sample(id: String = "1", distanceWalked: Int = 20, numberOfRestDays: Int = 0) -> CheckIn {
        return CheckIn(id: id, uid: UUID().uuidString, location: Coordinate.wellington.toCLLLocationCoordinate2D(), title: "Hotel \(id)", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something ", distanceWalked: distanceWalked, numberOfRestDays: numberOfRestDays, numberOfOffTrailDays: 0)
    }
    
    static var nilValue: CheckIn {
        var nilCheckIn = CheckIn()
        nilCheckIn._isNilValue = true
        return nilCheckIn
    }
    
    var isNil: Bool {
        return _isNilValue
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
