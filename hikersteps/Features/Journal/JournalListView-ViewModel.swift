//
//  JournalListView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import CoreLocation

extension JournalListView {
    
    protocol ViewModelProtocol: ObservableObject {
        init(journalService: JournalServiceProtocol)
        func loadJournals() async throws
        
        var journals: [Journal] { get }
    }
    
    /**
     The ViewModel for JournalListView
     */
    class ViewModel: ViewModelProtocol {
        
        private var journalService: JournalServiceProtocol
        
        @Published var journals: [Journal] = []
        
        required init(journalService: JournalServiceProtocol) {
            self.journalService = journalService
        }
        
        /**
         Returns an array of journals for the current user
         */
        func loadJournals() async throws {
            let result = try await journalService.getJournals()
            await MainActor.run {
                self.journals = result
            }
        }
    }
}
