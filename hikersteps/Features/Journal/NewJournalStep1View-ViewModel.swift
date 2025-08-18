//
//  NewHikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 13/08/2025.
//

import Foundation

extension NewJournalStep1View {
    
    protocol ViewModelProtocol: ObservableObject {
        init(trailService: TrailServiceProtocol)
        
        func loadTrails() async throws -> [Trail]
    }
    
    /**
     The ViewModel for HikeView controls interacting with the model to retrieve hike details including the checkins for the hike.
     */
    class ViewModel: ViewModelProtocol {
        var service: TrailServiceProtocol
        
        required init(trailService: any TrailServiceProtocol) {
            self.service = trailService
        }
        
        func loadTrails() async throws -> [Trail] {
            return try await service.fetchTrails()
        }
        
    }
}

