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
        
        init(journalService: JournalServiceProtocol, checkInService: CheckInServiceProtocol)
        
        func addJournal(trail: Trail, startLocation: CheckInAnnotation?) async throws -> Journal
    }
    
    /**
     The ViewModel for HikeView controls interacting with the model to retrieve hike details including the checkins for the hike.
     */
    class ViewModel: ViewModelProtocol {
        var journalService: JournalServiceProtocol
        var checkInService: CheckInServiceProtocol
        
        required init(journalService: JournalServiceProtocol, checkInService: CheckInServiceProtocol) {
            self.journalService = journalService
            self.checkInService = checkInService
        }
        
        func addJournal(trail: Trail, startLocation: CheckInAnnotation?) async throws -> Journal {
            guard let uid = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }
            
            // Add a new Journal
            var journal = Journal(uid: uid, name: trail.name)
            journal.trail = trail
            
            let id = try await journalService.addJournal(journal: journal)
            journal.id = id
            
            // Add the 'start' checkin
            if let location = startLocation?.coordinate {
                var startCheckIn = CheckIn(uid: uid, journalId: id, location: location)
                startCheckIn.type = "start"
                startCheckIn.title = trail.name
                let _ = try await checkInService.addCheckIn(checkIn: startCheckIn)
            }
            
            return journal
        }
        
    }
}

