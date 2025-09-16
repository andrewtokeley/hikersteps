//
//  CommentStripView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation

extension CommentStripView {
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        
        init(commentService: SocialServiceProtocol)
        
        /**
         All reactions (from all users) against this source
         */
        var reactions: [Reaction] { get }
        
        /**
         All comments (from all users) against this source
         */
        var comments: [Comment] { get }
        
        /**
         The context against which a reaction or comment is made
         */
        func setContext(_ context: SocialContext)
        
        /**
         The reaction the current user has made (or not) on a source
         */
        var currentReaction: Reaction { get }
        
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
        let commentService: SocialServiceProtocol
        
        var context: SocialContext?
        
        @Published var reactions: [Reaction] = []
        @Published var comments: [Comment] = []
        
        @Published var currentReaction: Reaction = Reaction.nilValue
        
        init(commentService: any SocialServiceProtocol) {
            self.commentService = commentService
        }
        
        func setContext(_ context: SocialContext) {
            self.context = context
        }
        
        /**
         You can only have one reaction per source/id so reselecting a reaction replaces anything that was there before
         */
        func selectedReaction(_ reactionType: ReactionType) async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            print("selected")
            if reactionType == .none {
                // remove anything that was there before
                if !currentReaction.isNil {
                    print("delete")
                    
                    // delete from firestore
                    try await commentService.deleteReaction(currentReaction)
                    
                    // remove local list
                    reactions.removeAll { $0.id == currentReaction.id }
                    
                    // clear selection
                    currentReaction = .nilValue
                } else {
                    // do nothing - selecting none when none is already selected does nothing
                }
            } else if currentReaction.reactionType != .none {
                // there's an existing reaction to change
                print("update")
                self.currentReaction.reactionType = reactionType
                try await commentService.updateReaction(currentReaction)
                
                // update the local copy
                if let index = reactions.firstIndex(where: {$0.id == currentReaction.id}) {
                    reactions[index] = self.currentReaction
                }
            } else {
                // add a new reaction
                print("add")
                self.currentReaction = Reaction(uid: context.uid, source: context.source, sourceId: context.sourceId, username: context.username, reactionType: reactionType)
                let id = try await commentService.addReaction(self.currentReaction)
                self.currentReaction.id = id
                self.reactions.append(self.currentReaction)
            }
        }
        
        func addReaction(_ reaction: Reaction) async throws -> String {
            let id = try await commentService.addReaction(reaction)
            return id
        }
        
        func loadComments() async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            let comments = try await commentService.getComments(source: context.source, sourceId: context.sourceId)
            self.comments = comments
            //self.comments = []
        }
        
        func loadReactions() async throws {
            guard let context = context else { throw ServiceError.generalError("Context not set") }
            let reactions = try await commentService.getReactions(source: context.source, sourceId: context.sourceId)
            
            // set the currentReaction if the current user has a reaction in here
            if let index = reactions.firstIndex(where:{$0.uid == context.uid}) {
                self.currentReaction = reactions[index]
            }
            self.reactions = reactions
        }
    }
    
}
        
