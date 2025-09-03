//
//  CheckInTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 17/08/2025.
//

import Testing
import FirebaseAuth

@testable import hikersteps

struct CheckInTests {
    let journalService = JournalService()
    let checkInService = CheckInService()
    var uid: String
    var journalId: String

    init() {
        self.uid = Auth.auth().currentUser?.uid ?? "123"
        self.journalId = "1"
    }

    @Test func deleteCheckIn() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            #expect(Bool(false))
            return
        }
        // create a checkIn and save
        let journalId = UUID().uuidString
        let new = CheckIn(uid: uid, journalId: journalId)
        let _ = try await checkInService.addCheckIn(checkIn: new)
        
        // get the checkins for adventure
        var checkIns = try await checkInService.getCheckIns(uid: uid, journalId: journalId)
        #expect(checkIns.count == 1)
        
        // delete it
        try await checkInService.deleteCheckIn(checkIn: checkIns[0])
        
        // get the checkins for adventure
        checkIns = try await checkInService.getCheckIns(uid: uid, journalId: journalId)
        #expect(checkIns.count == 0)

    }

}
