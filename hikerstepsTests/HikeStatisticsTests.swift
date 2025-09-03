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
    var journalId: String = "1" // fake id, ok here
    
    init() {
        self.uid = Auth.auth().currentUser?.uid ?? "123"
    }
    
    @Test func mainFlow() async throws {
        
        let checkIns = [
            CheckIn(
                uid: uid,
                journalId: journalId,
                type: "start",
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                journalId: journalId,
                distance: Measurement(value: 20, unit: .kilometers),
                numberOfRestDays: 1,
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                journalId: journalId,
                distance: Measurement(value: 5, unit: .kilometers),
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            ),
            CheckIn(
                uid: uid,
                journalId: journalId,
                distance: Measurement(value: 10, unit: .kilometers),
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            ),
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDistanceWalked.value == 35)
        #expect(statistics.totalDays == 3)
        #expect(statistics.totalRestDays == 1)
        #expect(statistics.longestDistance.value == 20)
        #expect(statistics.totalDistanceWalked(at: checkIns[2]).value == 25.0)
        #expect(statistics.totalDistanceWalked(at: checkIns[0]).value == 0)
        #expect(statistics.totalDistanceWalked(at: checkIns[1]).value == 20)
    }
    
    @Test func startCheckInOnly() async throws {
        let checkIns = [
            CheckIn(
                uid: uid,
                journalId: journalId,
                type: "start",
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays == 0)
        #expect(statistics.totalDistanceWalked.value == 0)
    }
    
    @Test func oneCheckInOnly() async throws {
        // not sure if we should allow this or force the first checkin to be of type = 'start'?
        let checkIns = [
            CheckIn(
                uid: uid,
                journalId: journalId,
                type: "day",
                distance: Measurement(value: 20, unit: .kilometers),
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays == 1)
        #expect(statistics.totalDistanceWalked.value == 20)
    }

    @Test func oneDay() async throws {
        let checkIns = [
            CheckIn(
                uid: uid,
                journalId: journalId,
                type: "start",
                date: Date(),
            ),
            CheckIn(
                uid: uid,
                journalId: journalId,
                distance: Measurement(value: 20, unit: .kilometers),
                date: Date(),
            )
        ]
        let statistics = JournalStatistics(checkIns: checkIns)
        
        #expect(statistics.totalDays == 1)
        #expect(statistics.totalDistanceWalked.value == 20)
    }
}
