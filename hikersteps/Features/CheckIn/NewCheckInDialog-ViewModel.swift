//
//  NewCheckInDialog-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 18/08/2025.
//

import Foundation
import FirebaseAuth

extension NewCheckInDialog {
    
    protocol ViewModelProtocol: ObservableObject {
        func addCheckIn(title: String, date: Date, notes: String, journalId: String) async throws -> CheckIn
    }
    
    class ViewModel: ViewModelProtocol {
        var checkInService: CheckInServiceProtocol
        
        init(checkInService: CheckInServiceProtocol) {
            self.checkInService = checkInService
        }
        
        func addCheckIn(title: String, date: Date, notes: String, journalId: String) async throws -> CheckIn {
            guard let uid = Auth.auth().currentUser?.uid else {
                throw ServiceError.unauthenticateUser
            }
            
            var new = CheckIn(uid: uid, adventureId: journalId)
            new.title = title
            new.notes = notes
            new.date = date
            
            let newId = try await checkInService.addCheckIn(checkIn: new)
            new.id = newId
            
            return new
        }
    }
}
