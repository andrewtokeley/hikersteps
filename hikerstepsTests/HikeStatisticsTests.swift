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
                distanceWalked: 5,
                date: Date(),
            ),
            CheckIn(
                distanceWalked: 20,
                numberOfRestDays: 1,
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            ),
            CheckIn(
                distanceWalked: 5,
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

}
