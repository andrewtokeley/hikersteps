//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import CoreLocation

extension HikeView {
    
    protocol ViewModelProtocol: ObservableObject {
        init(checkInService: CheckInServiceProtocol, hikeService: HikerServiceProtocol)
        
        func loadCheckIns(uid: String, hike: Hike) async throws -> [CheckIn]
        func saveCheckIn(_ checkIn: CheckIn) async throws
        func addCheckIn(_ checkIn: CheckIn) async throws
        func saveChanges(_ manager: CheckInManager) async throws
    }
    
    /**
     The ViewModel for HikeView controls interacting with the model to retrieve hike details including the checkins for the hike.
     */
    class ViewModel: ViewModelProtocol {

        private var checkInService: CheckInServiceProtocol
        private var hikeService: HikerServiceProtocol
        
        required init(checkInService: CheckInServiceProtocol, hikeService: HikerServiceProtocol) {
            self.checkInService = checkInService
            self.hikeService = hikeService
        }
        
        /**
         Loads checkins for the given hike and returns the results through the trailing closure
         */
        func loadCheckIns(uid: String, hike: Hike) async throws -> [CheckIn] {
            if let adventureId = hike.id {
                let checkIns = try await checkInService.getCheckIns(uid: uid, adventureId: adventureId)
                
                // refresh the hike statistics from the checkins
                try await hikeService.updateStatistics(hikeId: adventureId, statistics: HikeStatistics(checkIns: checkIns))
                return checkIns
            } else {
                print("missing hike id")
            }
            return []
        }
        
        /**
         Saves any changes made to the checkin. If the checkin has no changes then no action is taken.
         */
        func saveCheckIn(_ checkIn: CheckIn) async throws {
            try await checkInService.updateCheckIn(checkIn: checkIn)
        }
        
        func saveChanges(_ manager: CheckInManager) async throws {
            try await checkInService.save(manager: manager)
        }
        
        func addCheckIn(_ checkIn: CheckIn) async throws {
            // to do
        }
    }
}
