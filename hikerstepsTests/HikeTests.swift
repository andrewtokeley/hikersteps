//
//  HikeTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 13/08/2025.
//

import Testing
@testable import hikersteps

struct HikeTests {

    @Test func fetchHikes() async throws {
        let service = HikerService()
        
        let hikes = try await service.fetchHikes()
        
        #expect(hikes.count > 0)
        #expect(hikes.first?.id != nil)
    }

}
