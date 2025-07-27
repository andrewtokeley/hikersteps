//
//  CheckInManager.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/07/2025.
//

import Foundation

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
    @Published var checkIns: [CheckIn] {
        didSet {
            // initialise the annotations
            self.annotations = checkIns.map { CheckInAnnotation(checkIn: $0 )}
        }
    }
    @Published var selectedIndex: Int
    @Published var annotations: [CheckInAnnotation] = []
    
    var selectedCheckIn: CheckIn? {
        guard selectedIndex >= 0 else { return nil }
        return checkIns[selectedIndex]
    }
    
    init(checkIns: [CheckIn] = []) {
        self.checkIns = checkIns.sorted { $0.date > $1.date }
        self.selectedIndex = nilIndex
    }
    
    var isEmpty: Bool {
        return checkIns.isEmpty
    }
    
    func move(_ direction: NavigationDirection) {
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
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
            $0.checkInId == self.selectedCheckIn?.id }) {
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
    
}
