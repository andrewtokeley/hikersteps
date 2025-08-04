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
        let items = await withCheckedContinuation { continuation in
            service.getAccommodationLookups { items, error in
                continuation.resume(returning: items)
            }
        }
        // Verify
        #expect(items?.count ?? 0 > 0)
        
        if let firstItem = items?.first {
            #expect(firstItem.id != nil)
            #expect(firstItem.order == 1.0)
        } else {
            Issue.record("Nothing returned")
        }
    }

}
