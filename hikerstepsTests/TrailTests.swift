//
//  TrailTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 13/08/2025.
//

import Testing
@testable import hikersteps

struct TrailTests {

    @Test func fetchTrails() async throws {
        let service = TrailService()
        let trails = try await service.fetchTrails()
        
        #expect(trails.count > 0)
    }

}
