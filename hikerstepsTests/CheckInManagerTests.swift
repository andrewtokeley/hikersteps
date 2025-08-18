//
//  CheckInManagerTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 01/08/2025.
//

import Testing
import Foundation
@testable import hikersteps

struct CheckInManagerTests {
    let checkIns = [
        CheckIn(uid: "1", adventureId: "1", id: "1", title: "Title1", notes: "Some notes 1", distance: DistanceUnit(20, .km), date: Date())
        , CheckIn(uid: "1", adventureId: "1", id: "2", title: "Title2", notes: "Some notes 2", distance: DistanceUnit(30, .km), date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        , CheckIn(uid: "1", adventureId: "1", id: "3", title: "Title3", notes: "Some notes 3", distance: DistanceUnit(40, .km), numberOfRestDays: 2, numberOfOffTrailDays: 1, date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
    ]
    
    @Test func nextAvailableDateForFirstCheckIn() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        
        let latestDate = manager.checkIns.last!.date
        
        // should be the date of the last on plus the 2 rest days, 1 offTrailDay + 1
        if let nextAvailableDate = Calendar.current.date(byAdding: .day, value: 4, to: latestDate) {
            // should be the day after the last checkin and take into account the number of rest days
            #expect(Calendar.current.isDate(nextAvailableDate, inSameDayAs: manager.nextAvailableDate))
        } else {
            #expect(Bool(false))
        }
    }
    
    @Test func nextAvailableDateWhenOnlyAStart() async throws {
        let manager = CheckInManager(checkIns: [
            CheckIn(uid: "abs", adventureId: "123", type: "start", date: Date())
        ])
        // should be on the same day as the start checkin, rather than 1 day after
        #expect(Calendar.current.isDate(Date(), inSameDayAs: manager.nextAvailableDate))
    }
    
    @Test func dirtyUpdateTest() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        #expect(manager.isDirty == false)
        
        manager.checkIns[0].title = "New Title 1"
        #expect(manager.isDirty == true)
        #expect(manager.changes.modified.count == 1)
        #expect(manager.changes.modified.first?.title == "New Title 1")
        
        manager.resetDirtyState()
        #expect(manager.isDirty == false)
    }
    
    @Test func dirtyUpdateDelete() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        #expect(manager.isDirty == false)
        
        manager.checkIns.remove(at: 1)
        #expect(manager.isDirty == true)
        #expect(manager.changes.removed.count == 1)
        #expect(manager.changes.removed[0].title == "Title2")
    }
    
    @Test func undoChanges() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        #expect(manager.isDirty == false)
        
        manager.checkIns.remove(at: 1)
        manager.checkIns[0].notes = "Updated notes"
        #expect(manager.isDirty == true)
        manager.undoChanges()
        #expect(manager.isDirty == false)
        #expect(manager.checkIns[0].notes != "Updated notes")
        #expect(manager.checkIns.count == 3)
    }

    @Test func addCheckIn() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        manager.move(.start)
        
        // this should add the checkin at index 2 according to dates
        let new = manager.addCheckIn(hikeId: "1", uid: "4", location: Coordinate.wellington, date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
        
        // based on date should have been inserted here
        let index = manager.checkIns.firstIndex(of: new)
        #expect(index == 2)
        
        #expect(manager.selectedIndex == 2)
        #expect(manager.checkIns.count == 4)
        #expect(manager.isDirty == true)
        #expect(manager.changes.added.count == 1)
        #expect(manager.changes.added[0].uid == "4")
    }
    
    @Test func removeCheckIn() async throws {
        let manager = CheckInManager(checkIns: checkIns)
        
        
        //remove the currently selected checkin
        manager.move(.to(id: "2"))
        #expect(manager.selectedIndex == 1)
        
        manager.removeCheckIn(id: "2")
        
        #expect(manager.selectedIndex == 1)
        #expect(manager.isDirty == true)
        #expect(manager.changes.removed.count == 1)
        #expect(manager.changes.removed[0].id == "2")
    }
    
    @Test func clearingSelection() throws {
        let manager = CheckInManager(checkIns: checkIns)
        manager.move(.start)
        
        #expect(manager.selectedIndex == 0)
        manager.clearSelectedCheckIn()
        #expect(manager.selectedIndex == nilIndex)
        #expect(manager.selectedCheckIn.isNil)
        #expect(manager.selectedCheckIn == CheckIn.nilValue)
        print(manager.selectedCheckIn)
    }
}
