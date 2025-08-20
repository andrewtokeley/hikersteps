//
//  Adventure.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore

/**
 A Journal is the top level structure that includes information about a user's walk. The Journal id is used to associate `CheckIn` records to daily entries in the journal.
 */
struct Journal: Codable, Identifiable, FirestoreEncodable  {
    
    var id: String? = nil
    var description: String = ""
    var name: String = ""
    var isPublic: Bool = false
    var startDate: Date = Date()
    var uid: String = ""
    var userName: String = ""
    var trail: Trail = Trail()
    var statistics: JournalStatistics = JournalStatistics()
    var heroImageUrl: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case name
        case isPublic = "public"
        case startDate
        case uid
        case userName
        case trail
        case statistics
        case heroImageUrl
    }
    
    /**
     Primary constructor that accepts the required fields for a new Journal.
     
     - Parameters:
        - uid: the uid of the user this Journal is for
        - name: a name to give the Journal - typically defaults to the name of the trail
        - description: optional description for the Journal, defaults to empty string.
        - startDate: optional date for when the Journal's adventure begins, defaults to today.
     */
    init(uid: String, name: String, description: String = "", startDate: Date = Date()) {
        self.uid = uid
        self.name = name
        self.startDate = startDate
    }
        
    /**
     Used by Firestore to create  new Journal records from data returned from service calls.
     
     This is required to set defaults for values not returned by service calls. All Hike's properties are non-optional to allow direct binding in Views.
     */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        self.trail = try container.decodeIfPresent(Trail.self, forKey: .trail) ?? Trail()
        self.statistics = try container.decodeIfPresent(JournalStatistics.self, forKey: .statistics) ?? JournalStatistics()
        self.heroImageUrl = try container.decodeIfPresent(String.self, forKey: .heroImageUrl) ?? ""
    }
    
    /**
     Convenience property to construct a sample Hike for Previews and Testing.
     */
    static var sample: Journal {
        var hike = Journal(uid: "abc", name: "Bibb 2025", startDate: Calendar.current.date(from: DateComponents(year: 2021, month: 9, day: 28))!)
        hike.id = "23"
        hike.description = "Amazing trip!"
        hike.statistics = JournalStatistics.sample
        hike.heroImageUrl = StorageImage.sample.storageUrl ?? ""
        return hike
    }
    
    /**
     An instance of a Hike that represents nil.
     
     I've done this to allow Views that don't accept optional bindings to bind to say a selected Hike (that may not be selected). For example,
     ```
     @State private var selectedHike: Hike = Hike.nilValue
     
     if !selectedHike.isNil {
     // View expects non-optional binding
     CheckInView($selectedHike)
     }
     ```
     */
    static var nilValue: Journal {
        var nilHike = Journal(uid: "", name: "")
        nilHike._isNilValue = true
        return nilHike
    }
    
    /// Used to mark a CheckIn value as "nil"
    internal var _isNilValue: Bool = false
}
