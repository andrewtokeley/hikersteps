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
        init(hikeService: HikerServiceProtocol)
        var hikes: [Hike] { get }
        func loadHikes() async throws
    }
    
    class ViewModel: ViewModelProtocol {
        private var hikeService: HikerServiceProtocol
        
        @Published var hikes: [Hike] = []
        
        required init(hikeService: HikerServiceProtocol) {
            self.hikeService = hikeService
        }
        
        func loadHikes() async throws {
            let result = try await hikeService.fetchHikes()
            
            await MainActor.run {
                self.hikes = result
            }            
        }
        
    }
}
