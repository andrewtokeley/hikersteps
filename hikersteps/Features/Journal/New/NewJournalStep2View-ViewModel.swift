//
//  SelectStartView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/08/2025.
//

import Foundation
import FirebaseAuth

extension NewJournalStep2View {
    
    protocol ViewModelProtocol: ObservableObject {
        
        init(hikeService: JournalServiceProtocol, checkInService: CheckInServiceProtocol)
        
        func addHike(trail: Trail, startLocation: CheckInAnnotation?) async throws -> Hike
    }
    
    /**
     The ViewModel for HikeView controls interacting with the model to retrieve hike details including the checkins for the hike.
     */
    class ViewModel: ViewModelProtocol {
        var hikeService: JournalServiceProtocol
        var checkInService: CheckInServiceProtocol
        
        required init(hikeService: JournalServiceProtocol, checkInService: CheckInServiceProtocol) {
            self.hikeService = hikeService
            self.checkInService = checkInService
        }
        
        func addHike(trail: Trail, startLocation: CheckInAnnotation?) async throws -> Hike {
            guard let uid = Auth.auth().currentUser?.uid else { throw AuthErrorCode.nullUser }
            
            // Create the Journal
            var hike = Hike(uid: "abc", name: trail.name)
            hike.trail = trail
            hike.uid = uid
            
            let id = try await hikeService.addHike(hike: hike)
            hike.id = id
            
            // Add the 'start' checkin
            if let location = startLocation?.coordinate {
                var startCheckIn = CheckIn(uid: uid, adventureId: id, location: location)
                startCheckIn.type = "start"
                startCheckIn.title = trail.name
                let _ = try await checkInService.updateCheckIn(checkIn: startCheckIn)
            }
            
            return hike
        }
        
    }
}

