//
//  Adventure.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore

enum JournalVisibility: String {
    case justMe
    case friendsOnly
    case everyone
}

/**
 A Journal is the top level structure that includes information about a user's walk. The Journal id is used to associate `CheckIn` records to daily entries in the journal.
 */
struct Journal: Codable, Identifiable, FirestoreEncodable  {
    
    var id: String? = nil

    // Mandatory fields
    var uid: String = ""
    var startDate: Date
    
    
    var name: String = ""
    var description: String = ""
    var userName: String = ""
    var createdDate: Date = Date.distantPast
    var lastReadByOwnerDate: Date = Date.distantPast
    var trail: Trail = Trail()
    var statistics: JournalStatistics = JournalStatistics()
    var heroImageUrl: String = ""

    /// Historic field that is used by the website still and is the same as visibility == .everyone
    private var isPublic: Bool = false
    
    /// Not used by the application directly. Set by firestore service calls and app uses `visibility` instead
    private var _visibility: String = "justMe"
    
    // ...but in the rest of our code we get/set via an enum
    var visibility: JournalVisibility {
        get {
            return JournalVisibility(rawValue: _visibility) ?? .justMe
        }
        set {
            _visibility = newValue.rawValue
            
            // keep isPublic in sync until we fully deprecate it
            isPublic = newValue == .everyone ? true : false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case name
        case isPublic = "public"
        case startDate
        case createdDate
        case lastReadByOwnerDate
        case uid
        case userName
        case trail
        case statistics
        case heroImageUrl
        case _visibility = "visibility"
    }
    
    /**
     Primary constructor that accepts the required fields for a new Journal and sets defaults.
     
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
        self.isPublic = false
        self.visibility = .justMe
        self.createdDate = Date()
    }
        
    /**
     Used by Firestore to create  new Journal records from data returned from service calls.
     
     This is required to set defaults for values not returned by service calls. All Hike's properties are non-optional to allow direct binding in Views.
     */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date.distantPast
        self.lastReadByOwnerDate = try container.decodeIfPresent(Date.self, forKey: .lastReadByOwnerDate) ?? Date.distantPast
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        self.trail = try container.decodeIfPresent(Trail.self, forKey: .trail) ?? Trail()
        self.statistics = try container.decodeIfPresent(JournalStatistics.self, forKey: .statistics) ?? JournalStatistics()
        self.heroImageUrl = try container.decodeIfPresent(String.self, forKey: .heroImageUrl) ?? ""
        self.isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        
        if let visibility = try container.decodeIfPresent(String.self, forKey: ._visibility) {
            self._visibility = visibility
            // redefine isPublic to sync with visibility flag
            self.isPublic = visibility == JournalVisibility.everyone.rawValue ? true : false
        } else {
            // based on isPublic, for older records that haven't yet got a visibility flag
            self._visibility = (self.isPublic ? JournalVisibility.everyone.rawValue : JournalVisibility.justMe.rawValue )
        }
    }
    
    /**
     Convenience property to construct a sample Journql for Previews and Testing.
     */
    static var sample: Journal {
        var journal = Journal(uid: "abc",
                              name: "Bibb 2025",
                              startDate: Calendar.current.date(from: DateComponents(year: 2021, month: 9, day: 28))!)
        journal.id = "23"
        journal.description = "Amazing trip!"
        journal.statistics = JournalStatistics.sample
        journal.heroImageUrl = StorageImage.sample.storageUrl ?? ""
        journal.visibility = .justMe
        return journal
    }
    
    /**
     An instance of a Journal that represents nil.
     
     I've done this to allow Views that don't accept optional bindings to bind to say a selected Journal (that may not be selected). For example,
     ```
     @State private var selectedJournal:Journal = Journal.nilValue
     
     if !selectedJournal.isNil {
     
     // View expects non-optional binding
     CheckInView($selectedHike)
     }
     ```
     */
    static var nilValue: Journal {
        var nilJournal = Journal(uid: "", name: "")
        nilJournal._isNilValue = true
        return nilJournal
    }
    
    /// Used to mark a Journal value as "nil"
    internal var _isNilValue: Bool = false
}
