//
//  CheckIn.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation

/**
 All properties are marked as non-optional even if  they might not be stored in firebase. This allows us to bind directly to these properties from views (can't bind to optionals) and we handle converting fetched data in init(decoder:) for cases where there is no data for a field and setting a default.
 */
struct CheckIn: Codable, Identifiable, Equatable, FirestoreEncodable {
    
    /// Used to mark a CheckIn value as "nil"
    internal var _isNilValue: Bool = false

    /// The id of the document in firestore.
    @DocumentID var id: String?
    
    var uid: String = ""
    private var locationAsGeoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    var location: Coordinate {
        get { locationAsGeoPoint.toCoordinate() }
        set { locationAsGeoPoint = newValue.geoPoint }
    }
    var title: String = ""
    var address: String = ""
    var accommodation: LookupItem = LookupItem.noSelection()
    var notes: String = ""
    var date = Calendar.current.startOfDay(for: Date())
    var type: String = "day"
    var nearestTrailMarker: Double = 0

    private var distanceWalkedKm: Int = 0
    var distance: DistanceUnit {
        get { DistanceUnit(distanceWalkedKm, .km) }
        set { distanceWalkedKm = Int(newValue.convertTo(.km).number) }
    }
    
    var images: [StorageImage] = []
    var numberOfRestDays: Int = 0
    var numberOfOffTrailDays: Int = 0
    var adventureId: String = ""
    var customLinks: [CustomLink] = []
    var resupply: Bool = false
    var resupplyNotes: String = ""
    var isHeroImage: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case uid
        case date
        case locationAsGeoPoint = "location"
        case title
        case address
        case accommodation
        case notes
        case type
        case nearestTrailMarker
        case distanceWalkedKm = "distanceWalked"
        case images
        case numberOfRestDays
        case numberOfOffTrailDays
        case adventureId
        case customLinks
        case resupply
        case resupplyNotes
        case isHeroImage
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
        self.distanceWalkedKm = try container.decodeIfPresent(Int.self, forKey: .distanceWalkedKm) ?? 0
        self.images = try container.decodeIfPresent(Array.self, forKey: .images) ?? []
        self.numberOfRestDays = try container.decodeIfPresent(Int.self, forKey: .numberOfRestDays) ?? 0
        self.numberOfOffTrailDays = try container.decodeIfPresent(Int.self, forKey: .numberOfOffTrailDays) ?? 0
        self.adventureId = try container.decodeIfPresent(String.self, forKey: .adventureId) ?? ""
        self.customLinks = try container.decodeIfPresent(Array.self, forKey: .customLinks) ?? []
        self.resupply = try container.decodeIfPresent(Bool.self, forKey: .resupply) ?? false
        self.resupplyNotes = try container.decodeIfPresent(String.self, forKey: .resupplyNotes) ?? ""
        self.isHeroImage = try container.decodeIfPresent(Bool.self, forKey: .isHeroImage) ?? false
    }
        
    init(id: String? = nil, uid: String = "", type: String = "day", location: Coordinate = Coordinate.zero, title: String = "", notes: String = "", distance: DistanceUnit = DistanceUnit.zero(.km), numberOfRestDays: Int = 0, numberOfOffTrailDays: Int = 0, date: Date = Date(), images: [StorageImage] = [], isHeroImage: Bool = false, accommodation: LookupItem = LookupItem.noSelection()) {
        self.id = id
        self.uid = uid
        self.type = type
        self.locationAsGeoPoint = location.geoPoint
        self.title = title
        self.notes = notes
        self.distance = distance.convertTo(.km)
        self.numberOfRestDays = numberOfRestDays
        self.numberOfOffTrailDays = numberOfOffTrailDays
        self.date = date
        self.images = images
        self.accommodation = accommodation
        self.isHeroImage = isHeroImage
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
        lhs.distance == rhs.distance &&
        lhs.images == rhs.images &&
        lhs.numberOfRestDays == rhs.numberOfRestDays &&
        lhs.numberOfOffTrailDays == rhs.numberOfOffTrailDays &&
        lhs.adventureId == rhs.adventureId &&
        lhs.customLinks == rhs.customLinks &&
        lhs.resupply == rhs.resupply &&
        lhs.resupplyNotes == rhs.resupplyNotes &&
        lhs.isHeroImage == rhs.isHeroImage &&
        lhs._isNilValue == rhs._isNilValue
    }
    
    static var newWithDefaults: CheckIn {
        return CheckIn()
    }
    
    static func new(location: Coordinate) -> CheckIn {
        var new = newWithDefaults
        new.title = "Dropped Pin"
        new.location = location
        return new
    }
    
    static func sample(id: String = "1", distance: DistanceUnit = DistanceUnit(20, .km), numberOfRestDays: Int = 0) -> CheckIn {
        return CheckIn(id: id, uid: UUID().uuidString, location: Coordinate.wellington, title: "Hotel \(id)", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something ", distance: distance, numberOfRestDays: numberOfRestDays, numberOfOffTrailDays: 0)
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

