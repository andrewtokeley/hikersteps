//
//  HikeStatistics.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import Foundation

class HikeStatistics: Codable, FirestoreEncodable  {
    
    // Day Stats
    var totalDays = NumberUnit.zero(.days)
    var totalRestDays = NumberUnit.zero(.days)
    var latestCheckIn: Date = Date()
    
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
    
    convenience init() {
        self.init(checkIns: [])
    }
    
    init(checkIns: [CheckIn]) {
        updateFrom(checkIns)
    }
    
    /**
     Update all statistics based on the CheckInManager's collection of checkIns. This method can be called multiple times to refresh the statistics
     */
    func updateFrom(_ checkIns: [CheckIn]) {
        
        guard !checkIns.isEmpty else { return }
        
        // Sort check-ins by date to ensure proper chronological processing
        let sortedCheckIns = checkIns.sorted { $0.date < $1.date }
        
        // Day Stats
        let _totalDays = sortedCheckIns.reduce(0) { total, checkIn in
            return total + 1 + checkIn.numberOfRestDays
        }
        self.totalDays = NumberUnit(_totalDays, .days)
        
        let _totalRestDays = sortedCheckIns.reduce(0) { total, checkIn in
            return total + checkIn.numberOfRestDays
        }
        self.totalRestDays = NumberUnit(_totalRestDays, .days)
        self.latestCheckIn = sortedCheckIns.last?.date ?? Date()
        
        // Distance Stats
        self.totalDistanceWalked = sortedCheckIns.reduce(DistanceUnit.zero(.km)) { total, checkIn in
            return total + DistanceUnit(Double(checkIn.distanceWalked), .km)
        }
        
        let max = sortedCheckIns.map({ $0.distanceWalked }).max() ?? 0
        self.longestDistance = DistanceUnit(Double(max), .km)
        
    }
    
    static var sample: HikeStatistics {
        return HikeStatistics(checkIns: [
            CheckIn.sample(id: "1", distanceWalked: 24, numberOfRestDays: 0),
            CheckIn.sample(id: "2", distanceWalked: 52, numberOfRestDays: 1),
            CheckIn.sample(id: "3", distanceWalked: 33, numberOfRestDays: 0),
            CheckIn.sample(id: "4", distanceWalked: 32, numberOfRestDays: 1),
            CheckIn.sample(id: "5", distanceWalked: 34, numberOfRestDays: 0),
        ])
    }
}
