//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation

extension HikeView {
    
    protocol ViewModelProtocol: ObservableObject {
        var checkIns: [CheckIn] { get }
        func loadCheckIns(uid: String, hike: Hike)
    }
    
    class ViewModel: ViewModelProtocol {
        @Published var checkIns: [CheckIn] = []
        
        func loadCheckIns(uid: String, hike: Hike) {
            if let hikeId = hike.id {
                CheckInService.getCheckIns(uid: uid, adventureId: hikeId) { checkIns, error in
                    if let _ = error {
                        //TODO: log error
                        self.checkIns = []
                    } else if let checkIns = checkIns {
                        self.checkIns = checkIns
                    } else {
                        //TODO: proper exception handling
                        print("HomeView-ViewModel: that is unexpected")
                    }
                }
            }
        }
            
    }
    
    class ViewModelMock: ViewModel {
        override func loadCheckIns(uid: String, hike: Hike) {
            self.checkIns = [
                CheckIn(uid: uid, locationAsGeoPoint: Coordinate(latitude: -36.8485, longitude: 174.7633).toGeoPoint()),
                CheckIn(uid: uid, locationAsGeoPoint: Coordinate(latitude: -36.8455, longitude: 174.7613).toGeoPoint()),
            ]
        }
    }
}
