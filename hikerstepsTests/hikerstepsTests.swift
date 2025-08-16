//
//  hikerstepsTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 26/06/25.
//

import XCTest
@testable import hikersteps

final class hikerstepsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAdventureDecodeWithTrail() throws {
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
        let expected = Trail(key: "BB", name: "Bibbulmun")
        XCTAssertEqual(trail.id, expected.id)
        XCTAssertEqual(trail.name, expected.name)
        
    }
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
