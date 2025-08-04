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
        CheckIn(id: "1", title: "Title1", notes: "Some notes 1", distanceWalked: 20, date: Date())
        , CheckIn(id: "2", title: "Title2", notes: "Some notes 2", distanceWalked: 30, date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        , CheckIn(id: "3", title: "Title3", notes: "Some notes 3", distanceWalked: 40, date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
    ]
    
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
        let new = manager.addCheckIn(uid: "4", location: Coordinate.wellington.toCLLLocationCoordinate2D(), date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
        
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
