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
    case toIndex(index: Int)
}

enum DateAvailabilityResult: Int {
    case available = 0
    case entryExists
    case restOrOffTrailDaysExist
    case unknown
}

let nilIndex: Int = -1

/**
 The CheckInManager is an in-memory representation of a Journals Entries and their associated map annotations. It allows for sequential navigation up and down the entry list and provides functions to add/remove entries safely.
 
 Some properties are marked as @Published to allow Views to be aware of changes.
 */
class CheckInManager: ObservableObject {
    
    //MARK: - Published properties
    
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
    
    //MARK: - Convenience Computed Properties
    
    var isEmpty: Bool {
        return checkIns.isEmpty
    }
    
    //MARK: - Constructors
    
    /**
     Initialises a new manager
     */
    init(checkIns: [CheckIn] = []) {
        self.initialise(checkIns: checkIns)
    }
    
    /**
    Ensures the checkins and annotations are in sync and puts the selected state back to nothing
     */
    func initialise(checkIns: [CheckIn]) {
        self.checkIns = checkIns.sorted { $0.date < $1.date }
        self.annotations = checkIns.map { CheckInAnnotation(checkIn: $0 )}
        self.selectedIndex = nilIndex
        self.resetDirtyState()
    }
    
    // MARK: - Add/Remove CheckIns
    
    /**
     Returns when the next likely date is for a new journal entry.
     
     The next available date for a journal entry follows the following rules
     - if there are no entries yet, today
     - if there is only one entry and it's a 'start' entry, then the same day as the start
     - if there are many entries, return the date after the latest plus the number of rest days and off trail days.
     */
    var nextAvailableDate: Date {
        guard !checkIns.isEmpty else { return Date() }
        
        // The first entry after the "start" entry is on the same day.
        if checkIns.count == 1 && checkIns.first?.type == "start" {
            return Date()
        }
        
        let latestDate = checkIns.max(by: { $0.date < $1.date })?.date ?? Date()
        
        if let latestCheckIn = checkIns.last {
            // offset the latest checkin date by the number of rest days, off trail days and one more
            let offSet = Int(latestCheckIn.numberOfRestDays + latestCheckIn.numberOfOffTrailDays) + 1
            return Calendar.current.date(byAdding: .day, value: offSet, to: latestDate) ?? Date()
        }
        return Date()
    }
    
    /**
     Returns whether the given date is available for a new journal entry. We only allow one entry per day.
     */
    func isDateAvailable(_ date: Date) -> DateAvailabilityResult {
        print("Checking date \(date.formatted())")
        
        // check if any journal entries exist
        if let _ = checkIns.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            print(".entryExists")
            return .entryExists
        }
        
        // get the checkin that's closest to the date but still less than it
        let descendingOrder = checkIns.sorted { $0.date > $1.date }
        if let closestCheckIn = descendingOrder.first(where: { $0.date < date }) {
            print("closest checkin \(closestCheckIn.date.formatted())")
            let dateOffset = Int(closestCheckIn.numberOfRestDays + closestCheckIn.numberOfOffTrailDays)
            if let mustByAfterDate = Calendar.current.date(byAdding: .day, value: dateOffset, to: closestCheckIn.date) {
                print("must be after \(mustByAfterDate.formatted())")
                let compare = Calendar.current.compare(date, to: mustByAfterDate, toGranularity: .day)
                if compare == .orderedAscending || compare == .orderedSame {
                    print(".restOrOffTrailDaysExist")
                    return .restOrOffTrailDaysExist
                }
            }
        }
        print(".available")
        return .available
    }
    
    func addCheckIn(_ new: CheckIn) {
        let newAnnotation = CheckInAnnotation(checkIn: new)
        
        // insert the new checkin at the right location and move to it.
        if let index = checkIns.firstIndex(where: { $0.date > new.date }) {
            checkIns.insert(new, at: index)
            annotations.insert(newAnnotation, at: index)
            move(.toIndex(index: index))
        } else {
            checkIns.append(new)
            annotations.append(newAnnotation)
            move(.end)
        }
    }
    
    /**
     Adds a new instance of a CheckIn at the appropriate location in the checkins array based on it's date.
     
     The new instance is returned.
     */
    func addCheckIn(hikeId: String, uid: String, location: Coordinate, date: Date) -> CheckIn {
        let new = CheckIn(uid: uid, journalId: hikeId, location: location, date: date)
        
        addCheckIn(new)
        
        return new
    }
    
    func removeCheckIn(id: String) {
        guard let index = checkIns.firstIndex(where: { $0.id == id }) else { return }
        
        checkIns.remove(at: index)
        annotations.remove(at: index)
        
        // if the last chechin was removed then move to the last checkIn
        if selectedIndex > (checkIns.count - 1) {
            move(.latest)
        } else {
            // reselect the current index
            move(.toIndex(index: index))
        }
            
    }
    
    //MARK: - UItilities
    
    /**
     Returns a string representation for the day. Typically this is in the format "Day 21", but for the first day it will return "Start"
     
     Note the day number is based on dates and rest days, but ignoring off trail days. For example,
     */
    func dayDescription(_ checkIn: CheckIn) -> String {
        var description = ""
        
        if let index = checkIns.firstIndex(where: { $0 == checkIn }) {
            if index == 0 {
                description = "Start"
            } else {
                
                let checkInsToDate = checkIns.filter { $0.date < checkIn.date }
                let totalOffTrailData = checkInsToDate.reduce(0) { total, checkIn in
                    total + checkIn.numberOfOffTrailDays
                }
                if let startDate = checkIns.first?.date {
                    let dateDiffInDays = Calendar.current.dateComponents([.day], from: startDate, to: checkIn.date).day ?? 0
                    let actualDays = (dateDiffInDays + 1) - totalOffTrailData
                    
                    if checkIn.numberOfRestDays > 0 {
                        description += "Days \(actualDays)-\(actualDays + checkIn.numberOfRestDays)"
                    } else {
                        description = "Day \(actualDays)"
                    }
                }
                
            }
        }
        return description
    }
    
    func distanceToDate(_ checkIn: CheckIn) -> Measurement<UnitLength> {
        let checkInsSoFar = checkIns.filter { $0.date <= checkIn.date }
        let total = checkInsSoFar.reduce(0) { total, checkIn in
            total + Int(checkIn.distanceWalked.converted(to: .kilometers).value)
        }
        return Measurement(value: Double(total), unit: .kilometers)
    }
    
    func clearSelectedCheckIn() {
        selectedIndex = nilIndex
    }
    
    //MARK: - Navigation
    
    func move(_ direction: NavigationDirection) {
        
        guard !checkIns.isEmpty else { selectedIndex = nilIndex; return }
        
        // before moving make sure we copy any changes that were made to the selectedCheckIn back into the (value!) array.
        switch direction {
        case .start: moveStart()
        case .end: moveEnd()
        case .next: moveNext()
        case .previous: movePrevious()
        case .latest: moveLatest()
        case .to(let id): moveTo(id)
        case .toIndex(let index): moveToIndex(index)
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
    
    private func moveToIndex(_ index: Int) {
        guard index >= 0 && index < checkIns.count else { return }
        selectedIndex = index
    }
    
    /**
     Moves to the check with the given id
     */
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
    
    //MARK: - Annotations
    
    func addDropInAnnotation(location: Coordinate) {
        self.droppedPinAnnotation = CheckInAnnotation(coordinate: location, title: "Drop In")
    }
    func removeDropInAnnotation() {
        self.droppedPinAnnotation = nil
    }
    
    //MARK: - Tracking
    
    struct CheckInDiff {
        var added: [CheckIn] = []
        var removed: [CheckIn] = []
        var modified: [CheckIn] = []
        var reordered: Bool = false
        
        var hasDifferences: Bool {
            return !added.isEmpty || !removed.isEmpty || !modified.isEmpty || reordered
        }
    }
    
    /**
     Checks for changes in the underlying CheckIn array and returns a CheckInDiff result
     */
    private func diffCheckIns(old: [CheckIn], new: [CheckIn]) -> CheckInDiff {
        var diff = CheckInDiff()
        
        let oldMap = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
        let newMap = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
        
        // Detect removed
        for oldItem in old {
            if newMap[oldItem.id] == nil {
                diff.removed.append(oldItem)
            }
        }
        
        // Detect added + modified
        for newItem in new {
            if let oldItem = oldMap[newItem.id] {
                if oldItem != newItem {
                    diff.modified.append(newItem)
                }
            } else {
                diff.added.append(newItem)
            }
        }
        
        // Detect reordering (optional)
        let oldIDs = old.map { $0.id }
        let newIDs = new.map { $0.id }
        if oldIDs != newIDs {
            diff.reordered = true
        }
        
        return diff
    }
    
    /**
     A copy of checkins to track whether any checkins have changed/been removed/add
     */
    var originalCheckIns: [CheckIn] = []
    
    var isDirty: Bool {
        return self.changes.hasDifferences
    }
    
    var changes: CheckInDiff {
        return self.diffCheckIns(old: self.originalCheckIns, new: self.checkIns)
    }
    
    func undoChanges() {
        self.checkIns = self.originalCheckIns
    }
    
    func resetDirtyState() {
        self.originalCheckIns = self.checkIns
    }
}
