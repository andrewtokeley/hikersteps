//
//  HikeStatistics.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import Foundation

class JournalStatistics: Codable, FirestoreEncodable  {
    
    private var checkIns: [CheckIn] = []
    
    enum CodingKeys: String, CodingKey {
        case totalDays
        case latestCheckInDate = "latestCheckIn"
        case totalRestDays
        case totalDistanceKm
        case longestDistanceKm
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.totalDays = try container.decodeIfPresent(Int.self, forKey: .totalDays) ?? 0
        self.latestCheckInDate = try container.decodeIfPresent(Date.self, forKey: .latestCheckInDate) ?? Date()
        self.totalRestDays = try container.decodeIfPresent(Int.self, forKey: .totalRestDays) ?? 0
        self.totalDistanceKm = try container.decodeIfPresent(Int.self, forKey: .totalDistanceKm) ?? 0
        self.longestDistanceKm = try container.decodeIfPresent(Int.self, forKey: .longestDistanceKm) ?? 0
    }
    
    /**
     The total number of days on trail, including any rest days
     */
    var totalDays = 0
    
    /**
     Total number of days marked as rest days.
     */
    var totalRestDays = 0
    
    /**
     The date of the latest CheckIn
     */
    var latestCheckInDate: Date = Date()
    
    // Distance Stats
    
    /**
     Total distance walked in km.
     
     To convert simply use, totalDistanceWalked.convertTo(.mi)
     */
    private var totalDistanceKm: Int = 0
    var totalDistanceWalked: Measurement<UnitLength> {
        get {
            return Measurement(value: Double(totalDistanceKm), unit: .kilometers)
        }
        set {
            totalDistanceKm = Int(newValue.converted(to: .kilometers).value)
        }
    }
    
    /**
     Furthest distance that has been walked as stored in firestore
     */
    var longestDistanceKm: Int = 0
    var longestDistance: Measurement<UnitLength> {
        get {
            return Measurement(value: Double(longestDistanceKm), unit: .kilometers)
        }
        set {
            longestDistanceKm = Int(newValue.converted(to: .kilometers).value)
        }
    }
    
    /**
     Deprecated?
     */
    convenience init() {
        self.init(checkIns: [])
    }
    
    init(checkIns: [CheckIn]) {
        self.checkIns = checkIns
        updateFrom(checkIns)
    }
    
    func totalDistanceWalked(at checkIn: CheckIn) -> Measurement<UnitLength> {
        let checkInsSoFar = checkIns.filter { $0.date <= checkIn.date }
        let total = checkInsSoFar.reduce(0) { total, checkIn in
            total + Int(checkIn.distanceWalked.converted(to: .kilometers).value)
        }
        return Measurement(value: Double(total), unit: .kilometers)
    }
    
    /**
     Update all statistics based on an array of checkIns. This method can be called multiple times to refresh the statistics

     */
    func updateFrom(_ checkIns: [CheckIn]) {
        
        guard !checkIns.isEmpty else { return }
        
        // Sort check-ins by date to ensure proper chronological processing
        let sortedCheckIns = checkIns.sorted { $0.date < $1.date }
        
        // Day Stats
        
        let _totalRestDays = sortedCheckIns.reduce(0) { total, checkIn in
            return total + Int(checkIn.numberOfRestDays)
        }
        self.totalRestDays = _totalRestDays
        self.latestCheckInDate = sortedCheckIns.last?.date ?? Date()
        
        // Don't assume there is a checkin every day, instead work out the number of days between the 'start' checkin and the last one
        self.totalDays = 0
        
        // ignore the start checkin
        let walkingDays = sortedCheckIns.filter( {$0.type != "start" })
        if let first = walkingDays.first?.date, let last = walkingDays.last?.date {
            let components = Calendar.current.dateComponents([.day], from: first, to: last)
            if let days = components.day {
                self.totalDays = days + 1
            }
        }
            
        // Distance Stats
        self.totalDistanceKm = sortedCheckIns.reduce(0) { total, checkIn in
            return total + Int(checkIn.distanceWalked.value)
        }
        
        let max = sortedCheckIns.map({ $0.distanceWalked.converted(to: .kilometers).value }).max() ?? 0
        self.longestDistanceKm = Int(max)
        
    }
    
    static var sample: JournalStatistics {
        return JournalStatistics(checkIns: [
            CheckIn.sample(id: "1", distance: Measurement(value: 24, unit: .kilometers), numberOfRestDays: 0),
            CheckIn.sample(id: "2", distance: Measurement(value: 52, unit: .kilometers), numberOfRestDays: 0),
            CheckIn.sample(id: "3", distance: Measurement(value: 32, unit: .kilometers), numberOfRestDays: 0),
            CheckIn.sample(id: "4", distance: Measurement(value: 20, unit: .kilometers), numberOfRestDays: 0),
            CheckIn.sample(id: "5", distance: Measurement(value: 34, unit: .kilometers), numberOfRestDays: 0),
        ])
    }
}
