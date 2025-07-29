//
//  EditCheckInView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 28/07/2025.
//

import Foundation

extension EditCheckInView {
    
    protocol ViewModelProtocol: ObservableObject {
        /**
         This is a copy of the checkin that is being edited
         */
        var checkIn: CheckIn { get }
        
        
        var accommodationLookups: [LookupItem] { get }
        
        /**
         Retrieves a list of accommodation lookups
         */
        func loadAccommodationLookups(completion: ((Error?) -> Void)?)
        
        func save(completion: ((CheckIn, Error?) -> Void)?)
    }
    
    class ViewModel: ViewModelProtocol {
        @Published var checkIn: CheckIn
        @Published var accommodationLookups: [LookupItem] = []
        
        /**
         Initialise the viewmodel with the checkin being edited
         */
        init(checkIn: CheckIn) {
            self.checkIn = checkIn
        }
        
        func loadAccommodationLookups(completion: ((Error?) -> Void)? = nil) {
            LookupService.getAccommodationLookups { items, error in
                if let items = items {
                    self.accommodationLookups = items
                    completion?(nil)
                }
                if let error = error {
                    print(error)
                    completion?(error)
                }
            }
        }
        
        func save(completion: ((CheckIn, Error?) -> Void)? = nil) {
            // save to firestore
            
            // let the view know
            completion?(self.checkIn, nil)
        }
    }
    
    class ViewModelMock: ViewModel {
        
        override func loadAccommodationLookups(completion: (((any Error)?) -> Void)?) {
            self.accommodationLookups = [
                LookupItem(id: "1", name: "Tent", imageName: "tent"),
                LookupItem(id: "2", name: "House", imageName: "house")
            ]
            completion?(nil)
        }
        
        override func save(completion: ((CheckIn, Error?) -> Void)?) {
            completion?(checkIn, nil)
        }
        
        
    }
}
