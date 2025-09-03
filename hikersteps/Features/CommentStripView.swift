//
//  CommentStripView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import SwiftUI


struct CommentStripView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    @StateObject private var viewModel: ViewModel
    
    @State private var showComments: Bool = false
    @State private var showReactions: Bool = false
    
    /**
     The reaction, if any, the current user has made against the source
     */
    @State private var reaction: Reaction? = nil
    
    var source: SourceType
    var sourceId: String
    
    var uniqueReactionTypes: [ReactionType] {
        return Array(Set(viewModel.reactions.map { $0.reactionType }))
    }
    
    init(source: SourceType, sourceId: String, viewModel: ViewModel) {
        self.source = source
        self.sourceId = sourceId
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init(source: SourceType, sourceId: String) {
        self.init(source: source, sourceId: sourceId, viewModel: ViewModel(commentService: CommentService(), reactionService: ReactionService()))
    }
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    if viewModel.reactions.count > 0 {
                        ForEach(uniqueReactionTypes) { reactionType in
                            Image(systemName: reactionType.systemImageNameFilled)
                                .foregroundStyle(reactionType.colour)
                        }
                        Text("\(viewModel.reactions.count)")
                    }
                }
                .onTapGesture {
                    self.showReactions = true
                }
                
                Spacer()
                
                Group {
                    if viewModel.comments.count == 0 {
                        Text("No comments")
                    } else {
                        Text("\(viewModel.comments.count) comments")
                    }
                }
                .foregroundStyle(.secondary)
                .onTapGesture {
                    self.showComments = true
                }
            }
            .padding(.bottom, 10)
            
            HStack {
                VStack {
                    Image(systemName: "hand.thumbsup")
                        .font(.title2)
                    Text("Like")
                }
                .padding(.leading)
                .onTapGesture {
                    Task {
                        do {
                            try await viewModel.selectedReaction(.like)
                        } catch {
                            ErrorLogger.shared.log(error)
                        }
                    }
                }
                Spacer()
                VStack {
                    Image(systemName: "bubble")
                        .font(.title2)
                    Text("Comment")
                }
                .padding(.trailing)
                .onTapGesture {
                    self.showComments = true
                }
                
            }
        }
        .sheet(isPresented: $showComments) {
            Text("Comments")
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReactions) {
            Text("Reactions")
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                do {
                    viewModel.setContext(ViewModelContext(uid: auth.user.uid, username: auth.user.username, source: self.source, sourceId: self.sourceId))
                    try await viewModel.loadComments()
                    try await viewModel.loadReactions()
                } catch {
                    ErrorLogger.shared.log(error)
                }
            }
        }
    }
}

#Preview {
    CommentStripView(source: .journal, sourceId: "1", viewModel: CommentStripView.ViewModel(commentService: CommentService.Mock(), reactionService: ReactionService.Mock(sampleData: false)))
            .environmentObject(AuthenticationManager.forPreview(metric: false))
}
