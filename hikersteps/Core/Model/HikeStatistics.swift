//
//  HikeStatistics.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import Foundation

class HikeStatistics: Codable, FirestoreEncodable  {
    
    enum CodingKeys: String, CodingKey {
        case totalDays
        case latestCheckInDate = "latestCheckIn"
        case totalRestDays
        case totalDistanceWalked
        case longestDistance
    }
    
    /**
     The total number of days on trail, including any rest days
     */
    var totalDays = NumberUnit<Int>.zero(.days)
    
    /**
     Total number of days marked as rest days.
     */
    var totalRestDays = NumberUnit<Int>.zero(.days)
    
    /**
     The date of the latest CheckIn
     */
    var latestCheckInDate: Date = Date()
    
    // Distance Stats
    
    /**
     Total distance walked in km.
     
     To convert simply use, totalDistanceWalked.convertTo(.mi)
     */
    var totalDistanceWalked: DistanceUnit = DistanceUnit.zero(.km)
    
    /**
     Furthest distance that has been walked
     */
    var longestDistance: DistanceUnit = DistanceUnit.zero(.km)
    
    /**
     Deprecated?
     */
    convenience init() {
        self.init(checkIns: [])
    }
    
    init(checkIns: [CheckIn]) {
        updateFrom(checkIns)
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
            return total + checkIn.numberOfRestDays
        }
        self.totalRestDays = NumberUnit(_totalRestDays, .days)
        self.latestCheckInDate = sortedCheckIns.last?.date ?? Date()
        
        // Don't assume there is a checkin every day, instead work out the number of days between the 'start' checkin and the last one
        self.totalDays = NumberUnit(0, .days)
        
        // ignore the start checkin
        let walkingDays = sortedCheckIns.filter( {$0.type != "start" })
        if let first = walkingDays.first?.date, let last = walkingDays.last?.date {
            let components = Calendar.current.dateComponents([.day], from: first, to: last)
            if let days = components.day {
                self.totalDays = NumberUnit(days + 1, .days)
            }
        }
            
        // Distance Stats
        self.totalDistanceWalked = sortedCheckIns.reduce(DistanceUnit.zero(.km)) { total, checkIn in
            return total + checkIn.distance
        }
        
        let max = sortedCheckIns.map({ $0.distance.number }).max() ?? 0
        self.longestDistance = DistanceUnit(max, .km)
        
    }
    
    static var sample: HikeStatistics {
        return HikeStatistics(checkIns: [
            CheckIn.sample(id: "1", distance: DistanceUnit(24, .km), numberOfRestDays: 0),
            CheckIn.sample(id: "2", distance: DistanceUnit(52, .km), numberOfRestDays: 1),
            CheckIn.sample(id: "3", distance: DistanceUnit(33, .km), numberOfRestDays: 0),
            CheckIn.sample(id: "4", distance: DistanceUnit(32, .km), numberOfRestDays: 1),
            CheckIn.sample(id: "5", distance: DistanceUnit(34, .km), numberOfRestDays: 0),
        ])
    }
}
