//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation

extension HikeView {
    
    protocol ViewModelProtocol: ObservableObject {
        func loadCheckIns(uid: String, hike: Hike, completion: (([CheckIn]) -> Void)?)
        func saveCheckIn(_ checkIn: CheckIn, completion: ((Error?) -> Void)?)
        func addCheckIn(_ checkIn: CheckIn, completion: ((Error?) -> Void)?)
    }
    
    /**
     ViewModel for HikeView. Controls interacting with the model and also for maintaining annotation state (which feels wrong!)
     */
    class ViewModel: ViewModelProtocol {

        /**
         Loads checkins for the given hike and returns the results through the trailing closure
         */
        func loadCheckIns(uid: String, hike: Hike, completion: (([CheckIn]) -> Void)? = nil) {
            if let hikeId = hike.id {
                CheckInService.getCheckIns(uid: uid, adventureId: hikeId) { checkIns, error in
                    if let _ = error {
                        //TODO: log error
                    } else if let checkIns = checkIns {
                        completion?(checkIns)
                    } else {
                        //TODO: proper exception handling
                    }
                }
            } else {
                completion?([])
            }
        }
        
        func saveCheckIn(_ checkIn: CheckIn, completion: ((Error?) -> Void)?) {
            completion?(nil)
        }
        
        func addCheckIn(_ checkIn: CheckIn, completion: ((Error?) -> Void)?) {
            completion?(nil)
        }
    }
    
    class ViewModelMock: ViewModel {
        
        override func loadCheckIns(uid: String, hike: Hike, completion: (([CheckIn]) -> Void)? = nil) {
            let checkIns = [
                CheckIn(id: "2",  uid: "xxx", locationAsGeoPoint: Coordinate(latitude: -41.29, longitude: 174.7787).toGeoPoint(), title: "Wild Camping"),
                CheckIn(id: "1", uid: "xxx", locationAsGeoPoint: Coordinate(latitude: -41.39, longitude: 174.7787).toGeoPoint(), title: "Cherokee Point Camp"),
                CheckIn(id: "3", uid: "xxx", locationAsGeoPoint: Coordinate(latitude: -41.19, longitude: 174.7787).toGeoPoint(), title: "Brakenexk Speed Camp"),
                CheckIn(id: "4", uid: "xxx", locationAsGeoPoint: Coordinate(latitude: -41.16, longitude: 174.7787).toGeoPoint(), title: "Twolight Campsite")
                ]
                
//            self.annotations = checkIns.map { CheckInAnnotation(checkIn: $0)}
            completion?(checkIns)
        }
    }
}
