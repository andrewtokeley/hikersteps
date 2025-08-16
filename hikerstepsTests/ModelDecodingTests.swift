//
//  ModelDecodingTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Testing
import Foundation
@testable import hikersteps

@Suite
struct ModelDecodingTests {

    @Test
    func TrailDecode() async throws {
        // Simulate a Firestore document snapshot
        let firestoreData: [String: Any] = [
            "key": "BB",
            "value": "Bibbulmun"
        ]
        
        // Convert Firestore-like dictionary to JSON Data
        let jsonData = try JSONSerialization.data(withJSONObject: firestoreData)
        
        // Decode using JSONDecoder
        let decoder = JSONDecoder()
        let trail = try decoder.decode(Trail.self, from: jsonData)
        
        // Verify
        #expect(trail.id == "BB")
        #expect(trail.name == "Bibbulmun")
    }
}
