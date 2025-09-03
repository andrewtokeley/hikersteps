//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import CoreLocation

extension JournalView {
    
    protocol ViewModelProtocol: ObservableObject {
        init(checkInService: CheckInServiceProtocol, journalService: JournalServiceProtocol, userSettingsService: UserSettingsServiceProtocol)
        
        func loadCheckIns(uid: String, journal: Journal) async throws -> [CheckIn]
        func saveCheckIn(_ checkIn: CheckIn) async throws
        func addCheckIn(_ checkIn: CheckIn) async throws -> String
        func deleteCheckIn(_ checkIn: CheckIn) async throws
        func saveChanges(_ manager: CheckInManager) async throws
        func updateHeroImage(hikeId: String, urlString: String) async throws
        func updateUserSettings(settings: UserSettings) async throws
        func deleteJournal(journal: Journal) async throws
    }
    
    /**
     The ViewModel for HikeView controls interacting with the model to retrieve hike details including the checkins for the hike.
     */
    class ViewModel: ViewModelProtocol {

        private var checkInService: CheckInServiceProtocol
        private var journalService: JournalServiceProtocol
        private var userSettingsService: UserSettingsServiceProtocol
        
        required init(checkInService: CheckInServiceProtocol, journalService: JournalServiceProtocol, userSettingsService: UserSettingsServiceProtocol) {
            self.checkInService = checkInService
            self.journalService = journalService
            self.userSettingsService = userSettingsService
        }
        
        /**
         Update user settings, for example if the lastJournalId has been updated.
         */
        func updateUserSettings(settings: UserSettings) async throws {
            try await userSettingsService.updateUserSettings(settings)
        }
        
        /**
         Returns an array of checkins for the given journal.
         
         Whenever this func is called, the statistics about the Journal are recalculated and saved to the firestore Journal document.
         */
        func loadCheckIns(uid: String, journal: Journal) async throws -> [CheckIn] {
            if let journalId = journal.id {
                let checkIns = try await checkInService.getCheckIns(uid: uid, journalId: journalId)
                
                // refresh the hike statistics from the checkins
                try await journalService.updateStatistics(journalId: journalId, statistics: JournalStatistics(checkIns: checkIns))
                return checkIns
            } else {
                throw ServiceError.missingField("journal.id")
            }
        }
        
        /**
         Saves any changes made to the checkin. If the checkin has no changes then no action is taken.
         */
        func saveCheckIn(_ checkIn: CheckIn) async throws {
            try await checkInService.updateCheckIn(checkIn: checkIn)
        }
        
        func deleteCheckIn(_ checkIn: CheckIn) async throws {
            try await checkInService.deleteCheckIn(checkIn: checkIn)
        }
        
        func saveChanges(_ manager: CheckInManager) async throws {
            try await checkInService.save(manager: manager)
        }
        
        func addCheckIn(_ checkIn: CheckIn) async throws -> String {
            return try await checkInService.addCheckIn(checkIn: checkIn)
        }
        
        func updateHeroImage(hikeId: String, urlString: String) async throws {
            try await journalService.updateHeroImage(journalId: hikeId, urlString: urlString)
        }
        
        func deleteJournal(journal: Journal) async throws {
            try await journalService.deleteJournal(journal: journal, cascade: true)
        }
    }
}
