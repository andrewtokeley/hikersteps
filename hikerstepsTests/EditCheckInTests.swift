//
//  EditCheckInTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 10/09/2025.
//

import Foundation
import Testing
@testable import hikersteps

@MainActor
struct EditCheckInTests {
    
    @Test func saveTest() async throws {
        var checkInToEdit = CheckIn.sample(date: Date())
        checkInToEdit.image = StorageImage.sample
        
        let viewModel = EditCheckInView.ViewModel(checkIn: checkInToEdit, checkInService: CheckInService.Mock(), lookupService: LookupService.Mock(), storageService: StorageService.Mock())
        viewModel.save {
            //done
        }
        
    }

}
