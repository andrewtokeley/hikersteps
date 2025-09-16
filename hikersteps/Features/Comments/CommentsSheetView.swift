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
    @State private var isLoading: Bool = true
    @State private var showReactionsForId: CommentIdentifier?
    
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
        self.init(comments: comments, viewModel: ViewModel(context: context, commentService: SocialService()))
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
                                        
                                    CommentView(comment: comment)
                                    .onDeleteRequest {
                                        Task {
                                            do {
                                                try await viewModel.delete(comment)
                                            } catch {
                                                ErrorLogger.shared.log(error)
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
            .padding(.bottom, 5)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $showReactionsForId) { commentId in
                if let reactions = viewModel.commentReactions[commentId.id] {
                    ReactionsSheetView(reactions: reactions)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
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
                    }, label: {
                        Image(systemName: "paperplane.fill")
                            .rotationEffect(.degrees(45))
                            .frame(width: 25, height: 25)
                    })
                    .disabled(newComment.isEmpty)
                    
                }
                .padding()
            }
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
        commentService: SocialService.Mock()))
    .environmentObject(AuthenticationManager.forPreview(metric: false))
}
