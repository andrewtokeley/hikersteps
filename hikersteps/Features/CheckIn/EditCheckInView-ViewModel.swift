//
//  EditCheckInView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 28/07/2025.
//

import Foundation

extension EditCheckInView {
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        
        init(checkIn: CheckIn, checkInService: CheckInServiceProtocol, lookupService: LookupServiceProtocol)
        
        /**
         This is a copy of the checkin that is being edited
         */
        var checkIn: CheckIn { get }
        
        var accommodationLookups: [LookupItem] { get }
        
        /**
         Retrieves a list of accommodation lookups
         */
        func loadAccommodationLookups() async throws
        
        func save(checkIn: CheckIn) async throws
    }
    
    @MainActor
    final class ViewModel: ViewModelProtocol {
        private var checkInService: CheckInServiceProtocol
        private var lookupService: LookupServiceProtocol
        
        @Published var checkIn: CheckIn
        @Published var accommodationLookups: [LookupItem] = []
        
        /**
         Initialise the viewmodel with the checkin being edited
         */
        init(checkIn: CheckIn, checkInService: CheckInServiceProtocol, lookupService: LookupServiceProtocol) {
            self.checkIn = checkIn
            self.lookupService = lookupService
            self.checkInService = checkInService
        }
        
        func loadAccommodationLookups() async throws {
            let result = try await lookupService.getAccommodationLookups()
            self.accommodationLookups = result
        }
        
        func save(checkIn: CheckIn) async throws {
            try await checkInService.updateCheckIn(checkIn: checkIn)
        }
    }
    
//    class ViewModelMock: ViewModel {
//        
//        override func loadAccommodationLookups(completion: (((any Error)?) -> Void)?) {
//            self.accommodationLookups = [
//                LookupItem(id: "1", name: "Tent", imageName: "tent"),
//                LookupItem(id: "2", name: "House", imageName: "house")
//            ]
//            completion?(nil)
//        }
//        
//        override func save(completion: ((CheckIn, Error?) -> Void)?) {
//            completion?(checkIn, nil)
//        }
//        
//        
//    }
}
