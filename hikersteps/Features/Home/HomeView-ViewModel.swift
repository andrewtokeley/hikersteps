//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation

extension HomeView {
    
    protocol ViewModelProtocol: ObservableObject {
        var hikes: [Hike] { get }
        func loadHikes()
    }
    
    class ViewModel: ViewModelProtocol {
        @Published var hikes: [Hike] = []
        
        func loadHikes() {
            HikerService.fetchHikes { hikes, error in
                if let error = error {
                    self.hikes = []
                } else if let hikes = hikes {
                    self.hikes = hikes
                } 
            }
        }
    }
    
    class ViewModelMock: ViewModel {
        override init() {
            super.init()
            let uid = UUID().uuidString
            self.hikes = [
                Hike(id: UUID().uuidString, name: "PCT", uid: uid, isPublic: false),
                Hike(id: UUID().uuidString, name: "Te Araroa", uid: uid, isPublic: true),
                Hike(id: UUID().uuidString, name: "Bibbulmun", uid: uid),
            ]
        }
        override func loadHikes() {
            // do nothing
        }
    }
}
