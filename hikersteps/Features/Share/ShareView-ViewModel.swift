//
//  ShareView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 17/09/2025.
//

import Foundation

extension ShareView {
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        func updateShareStatus(journal: Journal, visibility: JournalVisibility) async throws
    }
    
    final class ViewModel: ViewModelProtocol {
        
        var journalService: any JournalServiceProtocol
        
        @Published var isSaving: Bool = false
        
        init(journalService: any JournalServiceProtocol) {
            self.journalService = journalService
        }
        
        func updateShareStatus(journal: Journal, visibility: JournalVisibility) async throws {
            guard journal.visibility != visibility else { return }
            isSaving = true
            var updateJournal = journal
            updateJournal.visibility = visibility
            try await journalService.updateJournal(journal: updateJournal)
            isSaving = false
        }
        
    }
}
