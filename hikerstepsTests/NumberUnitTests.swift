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
        let miles100 = DistanceUnit(100, .mi)
        #expect(miles100.number == 100)
        #expect(miles100.unit == .mi)
        
        let km = miles100.convertTo(.km)
        #expect(Int(km.number) == 160)
    }
    
    @Test func illegalConversion() async throws {
        let distance = DistanceUnit(20, .days)
        #expect(distance.unit == .km)
    }
    
    @Test func operations() async throws {
        let result1 = (DistanceUnit(20, .km) + DistanceUnit(20, .km))
        #expect(result1.number == 40)
        
        let result2 = (DistanceUnit(20, .km) - DistanceUnit(20, .km))
        #expect(result2 == DistanceUnit.zero(.km))
        
        var total = DistanceUnit(20, .km)
        total += DistanceUnit(20, .km)
        total -= DistanceUnit(10, .km)
        #expect(total.number == 30)
        
    }
    
}
