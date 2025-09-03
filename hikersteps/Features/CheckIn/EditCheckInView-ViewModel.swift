//
//  EditCheckInView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 28/07/2025.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

extension EditCheckInView {
    
    enum ImageAction {
        case doNothing
        case addOnly
        case deleteThenAdd
        case deleteOnly
    }
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        
        init(checkIn: CheckIn, checkInService: CheckInServiceProtocol, lookupService: LookupServiceProtocol, storageService: StorageServiceProtocol)
        
        /**
         This is a copy of the checkin that is being edited
         */
        var checkIn: CheckIn { get }
        
        var accommodationLookups: [LookupItem] { get }
        
        var newImageData: Data? { get set }
        var newImageContentType: String? { get set }
        var deleteImageOnSave: Bool { get set }
        
        /**
         Retrieves a list of accommodation lookups
         */
        func loadAccommodationLookups() async throws
        
        /**
         Intiate an update/add operation for the checkin/images
         */
        func save() async throws
    }
    
    @MainActor
    final class ViewModel: ViewModelProtocol {
        
        private var checkInService: CheckInServiceProtocol
        private var lookupService: LookupServiceProtocol
        private var storageService: StorageServiceProtocol
        
        @Published var checkIn: CheckIn
        @Published var accommodationLookups: [LookupItem] = []
        
        var newImageData: Data?
        var newImageContentType: String?
        var deleteImageOnSave: Bool = false
        
        /**
         Initialise the viewmodel with the checkin being edited
         */
        init(checkIn: CheckIn,
             checkInService: CheckInServiceProtocol,
             lookupService: LookupServiceProtocol,
             storageService: StorageServiceProtocol) {
            self.checkIn = checkIn
            self.lookupService = lookupService
            self.checkInService = checkInService
            self.storageService = storageService
        }
        
        func loadAccommodationLookups() async throws {
            let result = try await lookupService.getAccommodationLookups()
            self.accommodationLookups = result
        }
        
        
        /**
         Saves (adds or updates) the viewModel's version of the checkin (the one that the view is modifying) to firestore aswell as add/removing images appropriately
         
         Assuming it's successful, the checkIn's state will be copied back to the bound checkIn so that the parent view will update.
         */
        func save() async throws {
            guard let _ = Auth.auth().currentUser?.uid else { throw ServiceError.unauthenticatedUser }
            
            // Delete existing image if we've removed it
            if self.deleteImageOnSave {
                if let path = checkIn.images.first?.storagePath {
                    try await storageService.deleteImageFromStorage(path)
                    checkIn.images.remove(at: 0)
                }
            }
            
            // Add/Update checkin
            if let _ = checkIn.id {
                try await checkInService.updateCheckIn(checkIn: checkIn)
            } else {
                let id = try await checkInService.addCheckIn(checkIn: checkIn)
                self.checkIn.id = id
            }
            
            // add new image if the user added one
            if let data = self.newImageData, let contentType = self.newImageContentType {
                try await checkInService.addImage(to: self.checkIn, imageData: data, contentType: contentType, caption: "??")
            }
        }
        
    }
}
