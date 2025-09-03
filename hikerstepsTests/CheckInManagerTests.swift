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
        CheckIn(uid: "1", journalId: "1", id: "1", title: "Title1", notes: "Some notes 1",
                distance: Measurement(value: 20, unit: .kilometers),
                date: Date())
        , CheckIn(uid: "1", journalId: "1", id: "2", title: "Title2", notes: "Some notes 2",
                  distance: Measurement(value: 30, unit: .kilometers),
                  date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        , CheckIn(uid: "1", journalId: "1", id: "3", title: "Title3", notes: "Some notes 3",
                  distance: Measurement(value: 40, unit: .kilometers), numberOfRestDays: 2, numberOfOffTrailDays: 1,
                  date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
    ]
    
    @Test func dayDescriptions() async throws {
        let checkIns = [
            CheckIn(uid: "1", journalId: "1", id: "aa", type: "start", title: "Title1", notes: "Some notes 1",
                    date: Date())
            ,CheckIn(uid: "1", journalId: "1", id: "a", title: "Title1", notes: "Some notes 1",
                    distance: Measurement(value: 20, unit: .kilometers),
                    date: Date())
            , CheckIn(uid: "1", journalId: "1", id: "b", title: "Title2", notes: "Some notes 2",
                      distance: Measurement(value: 30, unit: .kilometers),
                      numberOfRestDays: 1,
                      date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
            , CheckIn(uid: "1", journalId: "1", id: "c", title: "Title3", notes: "Some notes 3",
                      distance: Measurement(value: 40, unit: .kilometers), numberOfRestDays: 1, numberOfOffTrailDays: 1,
                      date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
            , CheckIn(uid: "1", journalId: "1", id: "d", title: "Title3", notes: "Some notes 3",
                      distance: Measurement(value: 40, unit: .kilometers),
                      date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!)
        ]
        
        let manager = CheckInManager(checkIns: checkIns)
        
        // Start:       Date(), start
        // Day 1:       Date()
        // Days 2-3:    (Date() + 1) + (1 Rest)
        // Day 4-5:       Date() + 3 + 1R + 1OFF
        // Day 6        Date() + 6 (ignore off trail day)
        #expect(manager.dayDescription(checkIns[0]) == "Start")
        #expect(manager.dayDescription(checkIns[1]) == "Day 1")
        #expect(manager.dayDescription(checkIns[2]) == "Days 2-3")
        #expect(manager.dayDescription(checkIns[3]) == "Days 4-5")
        #expect(manager.dayDescription(checkIns[4]) == "Day 6")
        
    }
    
    @Test func isDateAvailable() async throws {
        
        let checkIns = [
            CheckIn(uid: "1", journalId: "1", id: "a", title: "Title1", notes: "Some notes 1",
                    distance: Measurement(value: 20, unit: .kilometers),
                    date: Date())
            , CheckIn(uid: "1", journalId: "1", id: "b", title: "Title2", notes: "Some notes 2",
                      distance: Measurement(value: 30, unit: .kilometers),
                      numberOfRestDays: 1,
                      date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
            , CheckIn(uid: "1", journalId: "1", id: "c", title: "Title3", notes: "Some notes 3",
                      distance: Measurement(value: 40, unit: .kilometers), numberOfRestDays: 1, numberOfOffTrailDays: 1,
                      date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
            , CheckIn(uid: "1", journalId: "1", id: "d", title: "Title3", notes: "Some notes 3",
                      distance: Measurement(value: 40, unit: .kilometers),
                      date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!)
        ]
        
        let manager = CheckInManager(checkIns: checkIns)
        
        //        Date()        Journal Day
        //        Date() + 1    Journal Day
        //        Date() + 2    Rest/Off
        //        Date() + 3    Journal Day
        //        Date() + 4    Rest/Off
        //        Date() + 5    Rest/Off
        //        Date() + 6    Journal Day
        //        Date() + 7    FREE!
        
        #expect(manager.isDateAvailable(Date()) == .entryExists)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 1, to: Date())!) == .entryExists)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 2, to: Date())!) == .restOrOffTrailDaysExist)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 3, to: Date())!) == .entryExists)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 4, to: Date())!) == .restOrOffTrailDaysExist)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 5, to: Date())!) == .restOrOffTrailDaysExist)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 6, to: Date())!) == .entryExists)
        #expect(manager.isDateAvailable(Calendar.current.date(byAdding: .day, value: 7, to: Date())!) == .available)
        
    }
    
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
            CheckIn(uid: "abs", journalId: "123", type: "start", date: Date())
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
        
        let checkIns = [
            CheckIn(uid: "1", journalId: "1", id: "a", title: "Title1", notes: "Some notes 1",
                    distance: Measurement(value: 20, unit: .kilometers),
                    date: Date()),
            CheckIn(uid: "1", journalId: "1", id: "b", title: "Title2", notes: "Some notes 2",
                      distance: Measurement(value: 30, unit: .kilometers),
                      numberOfRestDays: 1,
                      date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
            CheckIn(uid: "1", journalId: "1", id: "c", title: "Title1", notes: "Some notes 1",
                    distance: Measurement(value: 20, unit: .kilometers),
                    date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!),
            CheckIn(uid: "1", journalId: "1", id: "d", title: "Title2", notes: "Some notes 2",
                      distance: Measurement(value: 30, unit: .kilometers),
                      date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
            
        ]
        
        //
        // 0: Date
        // 1: Date + 1 + 1
        // insert here at Date + 3
        // 2: Date + 4
        // 3: Date + 5
        //
        let manager = CheckInManager(checkIns: checkIns)
        manager.move(.start)
        
        // this should add the checkin at index 2 according to dates
        let new = manager.addCheckIn(hikeId: "1", uid: "abc", location: Coordinate.wellington, date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
        
        // based on date should have been inserted here
        let index = manager.checkIns.firstIndex(of: new)
        #expect(index == 2)
        
        // should be automatically selected
        #expect(manager.selectedIndex == 2)
        #expect(manager.checkIns.count == 5)
        #expect(manager.isDirty == true)
        #expect(manager.changes.added.count == 1)
        #expect(manager.changes.added[0].uid == "abc")
    }
    
    @Test func removeStartCheckIn() async throws {
        var checkIns: [CheckIn] = [
            CheckIn.sample(date: Date()), // START
            CheckIn.sample(date: Date()) // DAY 1
        ]
        checkIns[0].type = "start"
        
        let idStart = checkIns[0].id!
        let idSecond = checkIns[1].id!
        
        let manager = CheckInManager(checkIns: checkIns)
        
        // remove start
        manager.removeCheckIn(id: idStart)
        
        #expect(manager.checkIns.count == 1)
        
        // the second checkin is now the first and marked as start
        #expect(checkIns[0].id == idSecond)
        #expect(checkIns[0].type == "start")
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
