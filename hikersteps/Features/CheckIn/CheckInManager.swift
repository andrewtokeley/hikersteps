//
//  CheckInManager.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/07/2025.
//

import Foundation
import CoreLocation

enum NavigationDirection {
    case next
    case previous
    case start
    case end
    case latest
    case to(id: String)
}

let nilIndex: Int = -1

class CheckInManager: ObservableObject {
    @Published var checkIns: [CheckIn] = []
    @Published var annotations: [CheckInAnnotation] = []
    @Published var droppedPinAnnotation: CheckInAnnotation?
    
    @Published var selectedIndex: Int = nilIndex {
        didSet {
            // Update selectedCheckIn when selectedIndex changes
            if selectedIndex != nilIndex && selectedIndex < checkIns.count {
                selectedCheckIn = checkIns[selectedIndex]
            } else {
                selectedCheckIn = CheckIn.nilValue
            }
        }
    }

    @Published var selectedCheckIn: CheckIn = CheckIn.nilValue {
        didSet {
            // Update the array when selectedCheckIn is modified
            if selectedIndex != nilIndex && selectedIndex < checkIns.count {
                checkIns[selectedIndex] = selectedCheckIn
                // the only thing that can be updated that affects annotations is the title
                annotations[selectedIndex].title = selectedCheckIn.title
            }
        }
    }
    
    init(checkIns: [CheckIn] = []) {
        self.initialise(checkIns: checkIns)
    }
    
    var isEmpty: Bool {
        return checkIns.isEmpty
    }
    
    /**
    Ensures the checkins and annotations are in sync and puts the selected state back to nothing
     */
    func initialise(checkIns: [CheckIn]) {
        self.checkIns = checkIns.sorted { $0.date < $1.date }
        self.annotations = checkIns.map { CheckInAnnotation(checkIn: $0 )}
        self.selectedIndex = nilIndex
    }
    
    /**
     Adds a new instance of a CheckIn at the appropriate location in the array of all check-ins based on it's date.
     */
    func addCheckIn(uid: String, location: CLLocationCoordinate2D, date: Date) -> CheckIn {
        let new = CheckIn(uid: uid, location: location, date: date)
        
        // insert the new checkin at the right location
        if let index = checkIns.firstIndex(where: { $0.date > date }) {
            checkIns.insert(new, at: index)
        } else {
            checkIns.append(new)
        }
        return new
    }
    
    func dayDescription(_ checkIn: CheckIn) -> String {
        if let index = checkIns.firstIndex(where: { $0 == checkIn }) {
            return "Day \(index)"
        }
        return ""
    }
    
    func move(_ direction: NavigationDirection) {
        
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        
        print("move \(direction)")
        
        // before moving make sure we copy any changes that were made to the selectedCheckIn back into the (value!) array.
        switch direction {
        case .start: moveStart()
        case .end: moveEnd()
        case .next: moveNext()
        case .previous: movePrevious()
        case .latest: moveLatest()
        case .to(let id): moveTo(id)
        }
        
        // Make sure the correct annotation is selected/deselected
        
        // Unselect currently selected annotation (if it exists)
        if let index = self.annotations.firstIndex(where: { $0.selected }) {
            self.annotations[index].selected = false
        }
        
        // select new one
        if let index = self.annotations.firstIndex(where: {
            $0.checkInId == self.selectedCheckIn.id }) {
            self.annotations[index].selected = true
        }
    }
    
    private func moveTo(_ id: String) {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        if let index = checkIns.firstIndex(where: { $0.id == id } ) {
            selectedIndex = index
        } else {
            selectedIndex = nilIndex
        }
    }
    
    private func moveNext() {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        if selectedIndex<checkIns.count-1 {
            selectedIndex += 1
        }
    }
    
    private func movePrevious() {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        if selectedIndex > 0 {
            selectedIndex -= 1
        }
    }
    
    private func moveStart() {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        selectedIndex = 0
    }
    
    private func moveEnd() {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        selectedIndex = checkIns.count-1
    }
    
    private func moveLatest() {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        let sorted = checkIns.sorted { $0.date > $1.date }
        if let index = checkIns.firstIndex(of: sorted.first!) {
            selectedIndex = index
        } else {
            selectedIndex = nilIndex
        }
    }
    
    func addDropInAnnotation(location: CLLocationCoordinate2D) {
        self.droppedPinAnnotation = CheckInAnnotation(coordinate: location, title: "Drop In")
    }
    func removeDropInAnnotation() {
        self.droppedPinAnnotation = nil
    }
}
