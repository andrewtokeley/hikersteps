//
//  EditHikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 09/08/2025.
//

import Foundation

extension EditHikeView {
    
    protocol ViewModelProtocol: ObservableObject {
        
        /**
         Initialise a new ViewModel for EditHikeView
         */
        init(hike: Hike, hikeService: any HikerServiceProtocol, trailService: TrailServiceProtocol)
                
        /**
        This is a copy of the hike being edited - we publsh changes so the parent can copy back to the master hike record that's being updated.
        */
        var hike: Hike { get }

        /**
         Intiate a save operation for the hike. If the Hike exists it will be updated, otherwise a new hike is created.
         
         - Returns: The id of the saved hike
         */
        func save() async throws -> String
        
        func fetchTrails() async throws -> [Trail]
    }
    
    class ViewModel: ViewModelProtocol {

        @Published var hike: Hike

        private var hikeService: HikerServiceProtocol
        private var trailService: TrailServiceProtocol
        
        required init(hike: Hike, hikeService: any HikerServiceProtocol, trailService: TrailServiceProtocol) {
            self.hike = hike
            self.hikeService = hikeService
            self.trailService = trailService
        }
        
        func save() async throws -> String {
            return try await hikeService.updateHike(hike: self.hike)
        }
        
        func fetchTrails() async throws -> [Trail] {
            return try await trailService.fetchTrails()
        }
        
    }
}

