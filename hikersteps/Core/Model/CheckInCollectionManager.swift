//
//  CheckInCollection.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 10/07/2025.
//

import Foundation

class CheckInCollectionManager: ObservableObject {
    @Published var checkIns: [CheckIn] = []
    @Published var selectedCheckIn: CheckIn? = nil
    
    func addCheckIn(_ checkIn: CheckIn) {
        checkIns.append(checkIn)
        
        // recalculate day property
    }
    
    func removeCheckIn(at index: Int) {
        checkIns.remove(at: index)
    }
}
