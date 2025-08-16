//
//  HikeStatisticsTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 31/07/2025.
//
import Foundation
import Testing
@testable import hikersteps

struct HikeStatisticsTests {

    @Test func mainFlow() async throws {
        let checkIns = [
            CheckIn(
                distance: DistanceUnit(5, .km),
                date: Date(),
            ),
            CheckIn(
                distance: DistanceUnit(20, .km),
                numberOfRestDays: 1,
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            ),
            CheckIn(
                distance: DistanceUnit(5, .km),
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            ),
        ]
        let statistics = HikeStatistics()
        statistics.updateFrom(checkIns)
        
        #expect(statistics.totalDistanceWalked.number == 30)
        #expect(statistics.totalDays.number == 4)
        #expect(statistics.totalRestDays.number == 1)
        #expect(statistics.longestDistance.number == 20)
        #expect(statistics.longestDistance.description == "20.0km")
    }
    
    @Test func startCheckInOnly() async throws {
        let checkIns = [
            CheckIn(
                type: "start",
                date: Date(),
            )
        ]
        let statistics = HikeStatistics()
        statistics.updateFrom(checkIns)
        
        #expect(statistics.totalDays.number == 0)
    }

    @Test func oneDay() async throws {
        let checkIns = [
            CheckIn(
                type: "start",
                date: Date(),
            ),
            CheckIn(
                distance: DistanceUnit(20, .km),
                date: Date(),
            )
        ]
        let statistics = HikeStatistics()
        statistics.updateFrom(checkIns)
        
        #expect(statistics.totalDays.number == 0)
    }
}
