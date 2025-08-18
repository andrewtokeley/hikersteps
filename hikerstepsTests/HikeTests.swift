//
//  HikeTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 13/08/2025.
//

import Testing
import Foundation
import UIKit
import FirebaseAuth

@testable import hikersteps

struct HikeTests {
    var uid: String
    let service = JournalService()
    
    init() {
        self.uid = Auth.auth().currentUser?.uid ?? "123"
    }
    
    @Test func fetchHikes() async throws {
        let hikes = try await service.getHikes()
        
        #expect(hikes.count > 0)
        #expect(hikes.first?.id != nil)
    }
    
    @Test func deleteHike() async throws {
        
        // create a hike
        var hike = Hike(uid: uid, name: "new", description: "testing")
        let id = try await service.addHike(hike: hike)
        hike.id = id
        
        // retrieve it to check it was saved
        let addedHike = try await service.getHike(id: id)
        #expect(addedHike?.id == id)
        
        // delete it
        if let _ = addedHike {
            try await service.deleteHike(hike: addedHike!, cascade: false)
            
            // try and retrieve it - it shouldn't be there
            let hike = try await service.getHike(id: id)
            #expect(hike == nil)
        }
    }
    
    @Test func cascadeDeleteHike() async throws {
        
        let storageService = StorageService()
        let checkInService = CheckInService()
        
        // create a hike
        let hike = Hike(uid: uid, name: "new", description: "testing")
        let newHikeId = try await service.addHike(hike: hike)
        
        // add a checkIn with an image
        let checkIn = CheckIn(uid: uid, adventureId: newHikeId)
        let newCheckInId = try await checkInService.addCheckIn(checkIn: checkIn)
        #expect(!newCheckInId.isEmpty)
        
        if let path = checkIn.getStoragePathForImage(1) {
            if let image = UIImage(named: "pct") {
                if let jpegData = image.jpegData(compressionQuality: 0.8) {
                    
                    var url: URL
                    var exists: Bool = false
                    
                    // add an image to storage
                    url = try await storageService.addImage(path, data: jpegData, contentType: "image/j-peg")
                    exists = await urlExists(url)
                    #expect(exists)
                    
                    // cascade delete Hike - this should remove everything
                    try await service.deleteHike(hike: hike, cascade: true)
                    
                    // check there's no image anymore
                    exists = await urlExists(url)
                    #expect(!exists)
                    
                    // check there is no checkin
                    let checkIns = try await checkInService.getCheckIns(uid: uid, adventureId: hike.id!)
                    #expect(checkIns.isEmpty)
                }
            }
        }
    }

    func urlExists(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD" // Only fetch headers, not the full content
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                return (200...299).contains(httpResponse.statusCode)
            }
            return false
        } catch {
            print("Error checking URL: \(error)")
            return false
        }
    }
}
