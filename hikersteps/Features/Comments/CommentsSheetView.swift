//
//  CommentsView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 04/09/2025.
//

import SwiftUI
import NukeUI

struct CommentIdentifier: Identifiable {
    let id: String
}

struct CommentsSheetView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    @State private var newComment: String = ""
    @State private var newReaction: ReactionType = ReactionType.none
//    @State private var commentReactions: [Reaction] = []
    @State private var isLoading: Bool = true
    
    @State private var showReactionsForId: CommentIdentifier?
//    @State private var showReactions: Bool = false
    
    @Binding var comments: [Comment]
    
    @StateObject private var viewModel: ViewModel
    @FocusState private var isFocused: Bool
    
    /**
     Test constructor to inject a Mock viewModel
     */
    init(comments: Binding<[Comment]>, viewModel: ViewModel) {
        _comments = comments
        _viewModel = StateObject(wrappedValue: viewModel)
        isFocused = true
    }
    
    /**
     Main constructor
     */
    init(comments: Binding<[Comment]>, context: SocialContext) {
        self.init(comments: comments, viewModel: ViewModel(context: context, commentService: CommentService(), reactionService: ReactionService()))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.comments.count > 0 {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(viewModel.comments.enumerated()), id: \.element.id) { index, comment in
                                HStack(alignment: .top) {
                                    
                                    ProfileImage(.small)
                                    
                                    VStack(alignment: .leading) {
                                        
                                        // Comment
                                        VStack(alignment: .leading) {
                                            Text(comment.username)
                                                .font(.caption)
                                                .bold()
                                            Text(comment.comment)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 15)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(15)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Actions
                                        HStack {
                                            Text(comment.createdDate.localisedTimeAgoDescription())
                                                .font(.caption)
                                                .padding(.leading)
                                            if (comment.uid == auth.user.uid) {
                                                Text("Delete")
                                                    .underline()
                                                    .font(.caption)
                                                    .onTapGesture {
                                                        Task {
                                                            do {
                                                                try await viewModel.delete(comment)
                                                            } catch {
                                                                ErrorLogger.shared.log(error)
                                                            }
                                                        }
                                                    }
                                            }
                                        }
                                        
                                    }
                                    Spacer()
                                    
                                    // Reactions
                                    VStack {
                                        Group {
                                            if viewModel.userLovedComment(comment) {
                                                Image(systemName: "heart.fill")
                                                    .foregroundStyle(.red)
                                            } else {
                                                Image(systemName: "heart")
                                            }
                                        }
                                        .onTapGesture {
                                            Task {
                                                do {
                                                    try await viewModel.toggleUserReaction(comment: comment)
                                                } catch {
                                                    ErrorLogger.shared.log(error)
                                                }
                                            }
                                        }
                                        if (comment.reactionCount) > 0 {
                                            Text("\(comment.reactionCount)")
                                                .padding(.top, 5)
                                                .onTapGesture {
                                                    showReactionsForId = CommentIdentifier(id: comment.id)
//                                                    DispatchQueue.main.async {
//                                                        showReactions = true
//                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("No comments yet")
                            .font(.title)
                            .bold()
                            .padding(.bottom)
                        Text("Go on, be the first!")
                    }
                    Spacer()
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $showReactionsForId) { commentId in
                if let reactions = viewModel.commentReactions[commentId.id] {
                    ReactionsSheetView(reactions: reactions)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                ProfileImage()
                TextField("Add a comment...", text: $newComment)
                    .padding(.all, 10)
                    .styleBorderLight(focused: true)
                    .focused($isFocused, equals: true)
                    .padding(.vertical)
                Button(action: {
                    Task {
                        do {
                            try await viewModel.addComment(newComment)
                        } catch {
                            ErrorLogger.shared.log(error)
                        }
                        newComment = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .frame(width: 25, height: 25)
                }
                
            }
            .padding()
        }
        .task {
            do {
                try await viewModel.loadComments()
                isLoading = false
            } catch {
                ErrorLogger.shared.log(error)
            }        
        }
        .onDisappear {
            // save the viewModel's comments back to the binding
            // possibly don't even need a binding if we maintain a comment count on CheckIn
            self.comments = self.viewModel.comments
        }
    }
        
//    func showReactions(_ comment: Comment) {
//        showReactionsForId = CommentIdentifier(id: comment.id)
//        showReactions = true
//    }
}

#Preview {
//    @Previewable @State var comments: [Comment] = []
    @Previewable @State var comments: [Comment] = [
        Comment(id: "1", uid: "1OZ0zM1OHac848DLo9oyifKFEg13", source: .checkIn, sourceId: "1", username: "tokes", profileUrlString: "", comment: "Go you!", reactionCount: 3),
        Comment(id: "2", uid: "sss", source: .checkIn, sourceId: "1", username: "nicole", profileUrlString: "", comment: "Love this Tokes!")
    ]
    CommentsSheetView(comments: $comments, viewModel: CommentsSheetView.ViewModel(
        context: SocialContext(source: .checkIn, sourceId: "1", auth: AuthenticationManager.forPreview()),
        commentService: CommentService.Mock(sampleData: true),
        reactionService: ReactionService.Mock()))
    .environmentObject(AuthenticationManager.forPreview(metric: false))
}
