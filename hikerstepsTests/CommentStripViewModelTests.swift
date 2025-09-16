//
//  CommentsViewModelTests.swift
//  hikerstepsTests
//
//  Created by Andrew Tokeley on 04/09/2025.
//

import Foundation
import Testing
@testable import hikersteps

@MainActor
struct CommentStripViewModelTests {

    var viewModel: CommentStripView.ViewModel
    
    init() {
        viewModel = CommentStripView.ViewModel(commentService: SocialService.Mock(), reactionService: ReactionService.Mock(sampleData: true))
        viewModel.setContext(SocialContext(source: .checkIn, sourceId: "212", auth: AuthenticationManager.forPreview()))
    }
    
    @Test func initialLoadTest() async throws {
        try await viewModel.loadReactions()
        #expect(viewModel.reactions.count == 0)
    }
    
    @Test func addReaction() async throws {
        try await viewModel.loadReactions()
        
        #expect(viewModel.reactions.count == 0)
        
        // simulate the user selecting a new reaction
        try await viewModel.selectedReaction(.love)
        #expect(viewModel.currentReaction.reactionType == .love)
        #expect(viewModel.reactions.count == 1)
        
        // select again and it should have removed the love
        try await viewModel.selectedReaction(.none)
        #expect(viewModel.currentReaction.reactionType == .none)
        #expect(viewModel.reactions.count == 0)
    }

    /**
     Tests that when we load reactions for the context, it also sets the currentReaction when it exists for the same context
     */
    @Test func loadSetsCurrent() async throws {
        try await viewModel.loadReactions()
        #expect(viewModel.currentReaction.reactionType == .none)
        
        // make sure there's a reaction
        try await viewModel.selectedReaction(.love)
        #expect(viewModel.currentReaction.reactionType == .love)
        #expect(viewModel.reactions.count == 1)
        
        // reload and test the currentReaction is there
        try await viewModel.loadReactions()
        
        #expect(viewModel.currentReaction.reactionType == .love)
    }
}
