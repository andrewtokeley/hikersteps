//
//  NumberUnitTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import Testing
@testable import hikersteps

struct NumberUnitTests {

    @Test func kmToMiConverstion() async throws {
        let miles100 = try? DistanceUnit(number: 100, unit: .mi)
        #expect(miles100?.number == 100)
        #expect(miles100?.unit == .mi)
        
        if let km = miles100?.convert(to: .km) {
            #expect(Int(km.number) == 160)
        }
    }

    @Test func illegalConversion() async throws {
        #expect( throws: NumberUnit.Errors.illegalUnit) {
            try DistanceUnit(number: 20, unit: .days)
        }
    }
}
