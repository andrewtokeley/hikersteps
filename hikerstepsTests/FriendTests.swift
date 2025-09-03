//
//  FriendTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 30/08/2025.
//

import Testing
import FirebaseAuth
@testable import hikersteps

struct FriendTests {
    let friendService = FriendService()
    let userService = UserService()
    let testUserId = "25175C39-7801-4E10-9A49-DC9AAAC6E491"

    @Test func addFriend() async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticatedUser
        }
        
        // simulate what happens when this user wants to be your friend
        try await friendService.addFriend(uid: testUserId, username: "nicole")
        
        // get the friend relationship back
        var myFriends = try await friendService.getFriends()
        #expect(myFriends.count == 1)
        
        if let friendRelationship = myFriends.first {
            #expect(friendRelationship.status == .pending)
        }
        
        try await friendService.setFriendStatus(friendUid: testUserId, status: .approved)
        
        myFriends = try await friendService.getFriends(status: .approved)
        if let friendRelationship = myFriends.first {
            #expect(friendRelationship.status == .approved)
        } else {
            #expect(Bool(false))
        }
        
        
    }

}
