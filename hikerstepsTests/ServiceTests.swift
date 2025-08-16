//
//  ServiceTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 20/07/2025.
//

import Testing
@testable import hikersteps

struct ServiceTests {
    
    @Test func fetchAccommodation() async throws {
        let service = LookupService()
        let items = try await service.getAccommodationLookups()
        
        // Verify
        #expect(items.count > 0)
        
        if let firstItem = items.first {
            #expect(firstItem.id != nil)
            #expect(firstItem.order == 1.0)
        } else {
            Issue.record("Nothing returned")
        }
    }

}
