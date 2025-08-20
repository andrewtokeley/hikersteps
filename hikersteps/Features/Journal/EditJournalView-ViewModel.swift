//
//  EditHikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 09/08/2025.
//

import Foundation

extension EditJournalView {
    
    protocol ViewModelProtocol: ObservableObject {
        
        /**
         Initialise a new ViewModel for EditHikeView
         */
        init(journal: Journal, journalService: any JournalServiceProtocol, trailService: TrailServiceProtocol)
                
        /**
        This is a copy of the hike being edited - we publsh changes so the parent can copy back to the master hike record that's being updated.
        */
        var journal: Journal { get }

        /**
         Updates changes to the hike
         */
        func updateCheckIn() async throws
        
        /**
         Adds a new hike to firestore.
         
         - Returns: The id of the saved hike
         */
        func addCheckIn() async throws -> String
        
        func fetchTrails() async throws -> [Trail]
    }
    
    class ViewModel: ViewModelProtocol {

        @Published var journal: Journal

        private var journalService: JournalServiceProtocol
        private var trailService: TrailServiceProtocol
        
        required init(journal: Journal, journalService: any JournalServiceProtocol, trailService: TrailServiceProtocol) {
            self.journal = journal
            self.journalService = journalService
            self.trailService = trailService
        }
        
        func addCheckIn() async throws -> String {
            return try await journalService.addJournal(journal: journal)
        }
        
        func updateCheckIn() async throws {
            try await journalService.updateJournal(journal: self.journal)
        }
        
        func fetchTrails() async throws -> [Trail] {
            return try await trailService.getTrails()
        }
        
    }
}

