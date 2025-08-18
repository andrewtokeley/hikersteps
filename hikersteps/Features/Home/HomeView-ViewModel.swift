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
        init(hikeService: JournalServiceProtocol)
        var hikes: [Hike] { get }
        func loadHikes() async throws
        /**
         Deletes the Journal and all JournalEntries
         */
        func deleteHike(hike: Hike) async throws
        
    }
    
    class ViewModel: ViewModelProtocol {
        private var hikeService: JournalServiceProtocol
        
        @Published var hikes: [Hike] = []
        
        required init(hikeService: JournalServiceProtocol) {
            self.hikeService = hikeService
        }
        
        func loadHikes() async throws {
            let result = try await hikeService.getHikes()
            
            await MainActor.run {
                self.hikes = result
            }            
        }
        
        func deleteHike(hike: Hike) async throws {
            
        }
        
    }
}
