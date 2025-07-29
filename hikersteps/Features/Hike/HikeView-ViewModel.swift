//
//  HikeView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import CoreLocation

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
                CheckIn(id: "0", uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.16, longitude: 174.7787), title: "Twolight Campsite", notes: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam", date: Date(), accommodation: LookupItem(id: "1", name: "Tent", imageName: "tent")),
                CheckIn(id: "1", uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.19, longitude: 174.7787), title: "Brakenexk Speed Camp", date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
                CheckIn(id: "2",  uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.29, longitude: 174.7787), title: "Wild Camping", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!),
                CheckIn(id: "3", uid: "xxx", location: CLLocationCoordinate2D(latitude: -41.39, longitude: 174.7787), title: "Cherokee Point Camp", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
                ]
            completion?(checkIns)
        }
    }
}
