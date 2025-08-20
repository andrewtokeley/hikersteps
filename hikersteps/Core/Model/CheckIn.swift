//
//  CheckIn.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import FirebaseAuth

/**
 
 */
struct CheckIn: Codable, Identifiable, Equatable, FirestoreEncodable {

    /// The id of the document in firestore.
    var id: String?
    
    /// Note: all properties are marked as non-optional even if  they might not be stored in firebase. This allows us to bind directly to these properties from views (can't bind to optionals) and we handle converting fetched data in init(decoder:) for cases where there is no data for a field and setting a default.
    ///
    
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
    
    /**
     This is the root "directory" of all images for this check-in. Currently this should only contain a single image.
     */
    func getStorageFolder() -> String? {
        guard !uid.isEmpty, !adventureId.isEmpty else { return nil }
        return "images/\(uid)/\(adventureId)/"
    }

    /**
     The path where the image should be stored. Currently there is only one image and it will always be at index == 1.
     */
    func getStoragePathForImage(_ index: Int) -> String? {
        guard let folder = self.getStorageFolder(), let id = id, index > 0 else { return nil }
        return folder + "\(id)/\(index)"
    }
    
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
    
    // MARK: - Initialisers
    
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
        
    /**
     This initialiser it typically only used for testing purposes. For App use it's more common to use Checkin(uid, adventureId)
     */
    init(uid: String, adventureId: String, id: String? = nil, type: String = "day", location: Coordinate = Coordinate.zero, title: String = "", notes: String = "", distance: DistanceUnit = DistanceUnit.zero(.km), numberOfRestDays: Int = 0, numberOfOffTrailDays: Int = 0, date: Date = Date(), images: [StorageImage] = [], isHeroImage: Bool = false, accommodation: LookupItem = LookupItem.noSelection()) {
        
        self.init(uid: uid, adventureId: adventureId, location: location)
        
        self.id = id
        self.type = type
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
     This is the primary initialiser. uid, adventureId and coordinate are mandatory fields to persist data about a CheckIn and should be presented as the context for the CheckIn.
     
     - Parameters
        - uid: uid of the currently logged in user
        - adventureId: id of the journal the checkIn is associated with
        - location: coordinates of the journal entry, typically defining where you finished the day
     */
    init(uid: String, adventureId: String, location: Coordinate) {
        self.uid = uid
        self.adventureId = adventureId
        self.location = location
    }
    
    /**
     Need to override default equalify check because GeoPoints and Dates are classes and won't necessarily compare with ==
     */
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        return lhs.id == rhs.id &&
        lhs.uid == rhs.uid &&
        lhs.adventureId == rhs.adventureId &&
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
        lhs.customLinks == rhs.customLinks &&
        lhs.resupply == rhs.resupply &&
        lhs.resupplyNotes == rhs.resupplyNotes &&
        lhs.isHeroImage == rhs.isHeroImage &&
        lhs._isNilValue == rhs._isNilValue
    }
    
//    static var newWithDefaults: CheckIn {
//        if let uid = Auth.auth().currentUser?.uid {
//        let adventureId = "1"
//        return CheckIn(uid: uid, adventureId: adventureId)
//    }
    
//    static func new(location: Coordinate) -> CheckIn {
//        var new = newWithDefaults
//        new.title = "Dropped Pin"
//        new.location = location
//        return new
//    }
    
    /**
     This func is only to be used for Previews and Testing, where you need to set an id (which you wouldn't normally have to). In either case the sample should not (and can't) be saved to firestore.
     */
    static func sample(id: String = "1", distance: DistanceUnit = DistanceUnit(20, .km), numberOfRestDays: Int = 0) -> CheckIn {
        let uid = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let adventureId = "123"
        return CheckIn(uid: uid, adventureId: adventureId, id: id, location: Coordinate.wellington, title: "Hotel \(id)", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something ", distance: distance, numberOfRestDays: numberOfRestDays, numberOfOffTrailDays: 0)
    }
    
    /**
     An instance of a CheckIn that represents nil.
     
     I've done this to allow Views that don't accept optional bindings to bind to say a selected CheckIn (that may not be selected). For example,
     ```
     @State private var $selectedCheckIn: CheckIn
     
     if !selectedCheckIn.isNil {
        // View expects non-optional binding
        CheckInView($selectedCheckIn)
     }
     ```
     */
    static var nilValue: CheckIn {
        var nilCheckIn = CheckIn(uid: "", adventureId: "")
        nilCheckIn._isNilValue = true
        return nilCheckIn
    }
    
    /**
     Returns whether the current CheckIn represents "nil"
     */
    var isNil: Bool {
        return _isNilValue
    }
    
    /// Used to mark a CheckIn value as "nil"
    internal var _isNilValue: Bool = false
}

