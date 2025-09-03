//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseAuth

extension HomeView {
    
    protocol ViewModelProtocol: ObservableObject {
        
        init(journalService: JournalServiceProtocol)
        var currentJournal: Journal? { get }
        
        func loadJournal(id: String) async throws
        
        func loadJournals() async throws
        
        /**
         Deletes the Journal and all JournalEntries
         */
        func deleteJournal(journal: Journal) async throws
    }
    
    class ViewModel: ViewModelProtocol {
        private var journalService: JournalServiceProtocol
        
        @Published var currentJournal: Journal?
        @Published var journals: [Journal] = []
        
        required init(journalService: JournalServiceProtocol) {
            self.journalService = journalService
        }
        
        func loadJournals() async throws {
            let result = try await journalService.getJournals()
            await MainActor.run {
                self.journals = result
            }
        }
        
        func loadJournal(id: String) async throws {
            guard !id.isEmpty else { return }
            
            let result = try await journalService.getJournal(id: id)
            await MainActor.run {
                self.currentJournal = result
            }
        }
        
        func deleteJournal(journal: Journal) async throws {
            try await journalService.deleteJournal(journal: journal, cascade: true)
        }
        
    }
}
