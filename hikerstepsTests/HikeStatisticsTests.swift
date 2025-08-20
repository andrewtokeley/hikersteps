//
//  HikeStatisticsTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 31/07/2025.
//
import Foundation
import FirebaseAuth
import Testing
@testable import hikersteps

struct HikeStatisticsTests {
    var uid: String
    var adventureId: String = "1" // fake id, ok here
    
    init() {
        self.uid = Auth.auth().currentUser?.uid ?? "123"
    }
    
    @Test func mainFlow() async throws {
        
        let checkIns = [
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                type: "start",
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                distance: DistanceUnit(20, .km),
                numberOfRestDays: 1,
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                distance: DistanceUnit(5, .km),
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            ),
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                distance: DistanceUnit(10, .km),
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            ),
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDistanceWalked.number == 35)
        #expect(statistics.totalDays.number == 3)
        #expect(statistics.totalRestDays.number == 1)
        #expect(statistics.longestDistance.number == 20)
    }
    
    @Test func startCheckInOnly() async throws {
        let checkIns = [
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                type: "start",
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays.number == 0)
        #expect(statistics.totalDistanceWalked.number == 0)
    }
    
    @Test func oneCheckInOnly() async throws {
        // not sure if we should allow this or force the first checkin to be of type = 'start'?
        let checkIns = [
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                type: "day",
                distance: DistanceUnit(20, .km),
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays.number == 1)
        #expect(statistics.totalDistanceWalked.number == 20)
    }

    @Test func oneDay() async throws {
        let checkIns = [
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                type: "start",
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                adventureId: adventureId,
                distance: DistanceUnit(20, .km),
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays.number == 1)
        #expect(statistics.totalDistanceWalked.number == 20)
    }
}
