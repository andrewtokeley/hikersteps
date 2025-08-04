//
//  Adventure.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore

/**
 A Hike represents a walk a hiker has done, or is doing, on one of the trails.
 */
struct Hike: Codable, Identifiable, FirestoreEncodable  {
    @DocumentID var id: String?
    var description: String = ""
    var name: String = ""
    var isPublic: Bool = false
    var startDate: Date = Date()
    var uid: String = ""
    var userName: String = ""
    var trail: Trail = Trail()
    var statistics: HikeStatistics = HikeStatistics()

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
    }
    
    init() {
        self.id = UUID().uuidString
    }
    
    init(name: String, description: String, startDate: Date) {
        self.id = UUID().uuidString
        self.name = name
        self.description = description
        self.startDate = startDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Attempt to decode each value, using a default if it's missing or null
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName) ?? ""
        self.trail = try container.decodeIfPresent(Trail.self, forKey: .trail) ?? Trail()
        self.statistics = try container.decodeIfPresent(HikeStatistics.self, forKey: .statistics) ?? HikeStatistics()
    }
    
    static var sample: Hike {
        var hike = Hike(name: "Tokes on TA 2021/22ppp", description: "Amazing trip!", startDate: Calendar.current.date(from: DateComponents(year: 2021, month: 9, day: 28))!)
        hike.id = "1"
        hike.statistics = HikeStatistics.sample
        print(hike.statistics)
        return hike
    }
}
