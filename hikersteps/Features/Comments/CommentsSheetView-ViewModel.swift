//
//  CommentsView-ViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 04/09/2025.
//

import Foundation
import FirebaseAuth

extension CommentsSheetView {
    
    @MainActor
    protocol ViewModelProtocol: ObservableObject {
        init(context: SocialContext, commentService: any SocialServiceProtocol)
        func addComment(_ comment: String) async throws
        func delete(_ comment: Comment) async throws
        func loadComments() async throws
        func toggleUserReaction(comment: Comment) async throws
    }
    
    final class ViewModel: ViewModelProtocol {
        
        let commentService: SocialServiceProtocol
        
        var context: SocialContext
        
        @Published var commentReactions: [String: [Reaction]] = [:]
        @Published var comments: [Comment] = []
        
        init(context: SocialContext, commentService: any SocialServiceProtocol) {
            self.context = context
            self.commentService = commentService
        }
        
        func loadComments() async throws {
            guard context.source == .checkIn else { return }
            comments = try await commentService.getComments(source: context.source, sourceId: context.sourceId)
            try await loadCommentReactions(comments)
        }
        
        func addComment(_ comment: String) async throws {
            var newComment = Comment(
                uid: context.uid,
                source: context.source,
                sourceId: context.sourceId,
                username: context.username,
                profileUrlString: context.profileUrl?.absoluteString ?? "",
                comment: comment)
            let id = try await commentService.addComment(newComment)
            newComment.id = id
            
            comments.append(newComment)
            comments = self.comments.sorted(by: { $0.createdDate > $1.createdDate})
        }
        
        func delete(_ comment: Comment) async throws {
            if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                try await commentService.deleteComment(comment, batch: nil)
                self.comments.remove(at: index)
                self.comments = self.comments
            }
        }
        
        func usersReactionToComment(_ comment: Comment) -> Reaction? {
            let reactions = commentReactions[comment.id] ?? []
            return reactions.first(where: { $0.uid == context.uid })
        }
        
        func userLovedComment(_ comment: Comment) -> Bool {
            return usersReactionToComment(comment)?.reactionType == .love
        }
        
        func toggleUserReaction(comment: Comment) async throws {
            
            var add: Bool = true
            
            // if current user has already liked comment, then delete the like
            if let reaction = usersReactionToComment(comment) {
                // current user has already reacted, so delete
                try await commentService.deleteReaction(reaction)
                    
                // remove user's recations from dictionary
                if var reactions = commentReactions[comment.id] {
                    reactions.removeAll(where: { $0.uid == context.uid })
                    commentReactions[comment.id] = reactions
                    commentReactions = commentReactions
                }
                
                // decrement reactionCount (this is for display purposes only)
                if let index = comments.firstIndex(where: {$0.id == comment.id}) {
                    comments[index].reactionCount -= 1
                    comments[index] = comments[index]
                }
                
                //
                add = false
            }
            
            if add {
                var reaction = Reaction(uid: context.uid, source: .comment, sourceId: comment.id, username: context.username, reactionType: .love)
                let id = try await commentService.addReaction(reaction)
                reaction.id = id
                var reactions = commentReactions[comment.id] ?? []
                reactions.append(reaction)
                commentReactions[comment.id] = reactions
                commentReactions = commentReactions
                
                // increment reactionCount (this is for display purposes only)
                if let index = comments.firstIndex(where: {$0.id == comment.id}) {
                    comments[index].reactionCount += 1
                    comments[index] = comments[index]
                }
            }
        }
        
        func loadCommentReactions(_ comments: [Comment]) async throws {
            let commentIds = comments.map { $0.id }
            let reactions = try await commentService.getReactions(source: .comment, sourceIds: commentIds)
            
            var result: [String: [Reaction]] = [:]
            for comment in comments {
                let id = comment.id
                result[id] = reactions.filter { $0.sourceId == id }
                
                // check whether the reationCounts are right (shouldn't happen unless we manually delete/add reactions on the server
                let count = result[comment.id]?.count ?? 0
                if comment.reactionCount != count {
                    try await commentService.updateReactionCount(comment, to: count)
                }
            }
            
            commentReactions = result
        }
    }
}
