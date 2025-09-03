//
//  CommentStripView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation

extension CommentStripView {
    
    /**
     Requiired data to describe the context of the comment strip.
     */
    struct ViewModelContext {
        let uid: String
        let username: String
        let source: SourceType
        let sourceId: String
    }
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        
        init(commentService: CommentServiceProtocol, reactionService: ReactionServiceProtocol)
        
        /**
         This is a copy of the checkin that is being edited
         */
        var reactions: [Reaction] { get }
        var comments: [Comment] { get }
        
        func setContext(_ context: ViewModelContext)
        
        /**
         The reaction the current user has made (or not) on a source
         */
        var currentReaction: Reaction? { get }
        
        /**
         Loads comments for source
         */
        func loadComments() async throws
        
        /**
         Loads reactions for source
         */
        func loadReactions() async throws
        
        /**
         Adds a new reaction to a source and returns the readtion's id
         */
        func addReaction(_ reation: Reaction) async throws -> String
        
        func selectedReaction(_ reactionType: ReactionType) async throws
    }
    
    @MainActor
    final class ViewModel: ViewModelProtocol {
        let commentService: CommentServiceProtocol
        let reactionService: ReactionServiceProtocol
        var context: ViewModelContext?
        
        @Published var reactions: [Reaction] = []
        @Published var comments: [Comment] = []
        
        @Published var currentReaction: Reaction? = nil
        
        init(commentService: any CommentServiceProtocol, reactionService: any ReactionServiceProtocol) {
            self.commentService = commentService
            self.reactionService = reactionService
        }
        
        func setContext(_ context: ViewModelContext) {
            self.context = context
        }
        
        /**
         You can only have one reaction per source/id so reselecting a reaction replaces anything that was there before
         */
        func selectedReaction(_ reactionType: ReactionType) async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            
            if let currentReaction = currentReaction {
                if currentReaction.reactionType == reactionType {
                    // selected the same reaction, this toggles it off and deletes it
                    try await reactionService.deleteReaction(currentReaction)
                    self.currentReaction = nil
                    self.reactions.removeAll { $0.id == currentReaction.id }
                } else {
                    // update the reaction to the new reactiontype
                    self.currentReaction?.reactionType = reactionType
                    try await reactionService.updateReaction(currentReaction)
                }
            } else {
                // add a new reaction
                self.currentReaction = Reaction(uid: context.uid, source: context.source, sourceId: context.sourceId, username: context.username, reactionType: reactionType)
                let id = try await reactionService.addReaction(self.currentReaction!)
                self.currentReaction!.id = id
                self.reactions.append(self.currentReaction!)
            }
        }
        
        func addReaction(_ reaction: Reaction) async throws -> String {
            let id = try await reactionService.addReaction(reaction)
            return id
        }
        
        func loadComments() async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            let comments = try await commentService.getComments(source: context.source, sourceId: context.sourceId)
            self.comments = comments
        }
        
        func loadReactions() async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            let reactions = try await reactionService.getReactions(source: context.source, sourceId: context.sourceId)
            self.reactions = reactions
        }
    }
    
}
        
