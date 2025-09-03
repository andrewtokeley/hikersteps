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
    
    // The firestore value for distance is always in km.
    private var _distanceWalkedKm: Int = 0
    
    // The distance property is what the app uses and regardless of the unit that is set, it sets the distanceWalkedKm property appropriately. The value returned by the property is always in the unit of the user's preference.
    var distanceWalked: Measurement<UnitLength> {
        get {  Measurement(value: Double(_distanceWalkedKm), unit: UnitLength.kilometers) }
        set { _distanceWalkedKm = Int(newValue.converted(to: .kilometers).value) }
    }
    
    var numberOfRestDays: Int = 0
    var numberOfOffTrailDays: Int = 0
    
    var images: [StorageImage] = []
    var journalId: String = ""
    var customLinks: [CustomLink] = []
    var resupply: Bool = false
    var resupplyNotes: String = ""
    var isHeroImage: Bool = false
    
    /**
     This is the root "directory" of all images for this check-in. Currently this should only contain a single image.
     */
    func getStorageFolder() -> String? {
        guard !uid.isEmpty, !journalId.isEmpty else { return nil }
        return "images/\(uid)/\(journalId)/"
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
        case nearestTrailMarker = "nearestTrailMarker"
        case _distanceWalkedKm = "distanceWalked"
        case images
        case numberOfRestDays
        case numberOfOffTrailDays
        case journalId = "adventureId"
        case customLinks
        case resupply
        case resupplyNotes
        case isHeroImage
    }
    
    // MARK: - Initialisers
    
    /**
     This initialiser it typically only used for testing purposes. For App use it's more common to use Checkin(uid, adventureId)
     */
    init(uid: String, journalId: String, id: String? = nil, type: String = "day", location: Coordinate = Coordinate.zero, title: String = "", notes: String = "", distance: Measurement<UnitLength> = Measurement(value: 0, unit: .kilometers), numberOfRestDays: Int = 0, numberOfOffTrailDays: Int = 0, date: Date = Date(), images: [StorageImage] = [], isHeroImage: Bool = false, accommodation: LookupItem = LookupItem.noSelection()) {
        
        self.init(uid: uid, journalId: journalId, location: location)
        
        self.id = id
        self.type = type
        self.title = title
        self.notes = notes
        self.distanceWalked = distance.converted(to: .kilometers)
        self.numberOfRestDays = numberOfRestDays
        self.numberOfOffTrailDays = numberOfOffTrailDays
        self.date = date
        self.images = images
        self.accommodation = accommodation
        self.isHeroImage = isHeroImage
    }
    
    /**
     This is the primary initialiser. uid, adventureId and coordinate are mandatory fields to persist data about a CheckIn and should be presented as the context for the new CheckIn.
     
     - Parameters
     - uid: uid of the currently logged in user
     - adventureId: id of the journal the checkIn is associated with
     - location: coordinates of the journal entry, typically defining where you finished the day
     */
    init(uid: String, journalId: String, location: Coordinate) {
        self.uid = uid
        self.journalId = journalId
        self.location = location
    }
    
    /**
     Initiaiser used by firestore to rehydrate struct
     */
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
        self._distanceWalkedKm = try container.decodeIfPresent(Int.self, forKey: ._distanceWalkedKm) ?? 0
        self.images = try container.decodeIfPresent(Array.self, forKey: .images) ?? []
        self.numberOfRestDays = try container.decodeIfPresent(Int.self, forKey: .numberOfRestDays) ?? 0
        self.numberOfOffTrailDays = try container.decodeIfPresent(Int.self, forKey: .numberOfOffTrailDays) ?? 0
        self.journalId = try container.decodeIfPresent(String.self, forKey: .journalId) ?? ""
        self.customLinks = try container.decodeIfPresent(Array.self, forKey: .customLinks) ?? []
        self.resupply = try container.decodeIfPresent(Bool.self, forKey: .resupply) ?? false
        self.resupplyNotes = try container.decodeIfPresent(String.self, forKey: .resupplyNotes) ?? ""
        self.isHeroImage = try container.decodeIfPresent(Bool.self, forKey: .isHeroImage) ?? false
    }
        
    // MARK: - Custom Equality
    
    /**
     Need to override default equalify check because GeoPoints and Dates are classes and won't necessarily compare with ==
     */
    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        return lhs.id == rhs.id &&
        lhs.uid == rhs.uid &&
        lhs.journalId == rhs.journalId &&
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
        lhs.customLinks == rhs.customLinks &&
        lhs.resupply == rhs.resupply &&
        lhs.resupplyNotes == rhs.resupplyNotes &&
        lhs.isHeroImage == rhs.isHeroImage &&
        lhs._isNilValue == rhs._isNilValue
    }
    
    // MARK: - Null
    
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
        var nilCheckIn = CheckIn(uid: "", journalId: "")
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
    
    // MARK: - Testing Helpers
    
    /**
     This func is only to be used for Previews and Testing, where you need to set an id (which you wouldn't normally have to). In either case the sample should not (and can't) be saved to firestore.
     */
    static func sample(id: String = "1", distance: Measurement<UnitLength> = Measurement(value: 20, unit: .kilometers), numberOfRestDays: Int = 0) -> CheckIn {
        let uid = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let journalId = "123"
        var checkIn = CheckIn(uid: uid, journalId: journalId, id: id, location: Coordinate.wellington, title: "Hotel \(id)", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something ", distance: distance, numberOfRestDays: numberOfRestDays, numberOfOffTrailDays: 0)
        checkIn.id = UUID().uuidString
        return checkIn
    }
    
    
    /**
     Returns a random, but valid checkIn, for the given date
     */
    static func sample(date: Date) -> CheckIn {
        let uid = Auth.auth().currentUser?.uid ?? UUID().uuidString
        var checkIn = CheckIn(uid: uid, journalId: UUID().uuidString, location: Coordinate.zero)
        checkIn.date = date
        checkIn.id = UUID().uuidString
        return checkIn
    }
}

