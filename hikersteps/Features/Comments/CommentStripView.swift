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
     Local store of selected reaction - we hold here rather than binding directly to viewmodel so that the viewModel can update firestore based on any changes to this.
     */
    @State private var editReactionType: ReactionType = ReactionType.none
    
    /**
     The reaction, if any, the current user has made against the source
     */
    //@State private var reaction: Reaction = Reaction.nilValue
    
    var source: SourceType
    var sourceId: String
    
    var uniqueReactionTypes: [ReactionType] {
        return Array(Set(viewModel.reactions.map { $0.reactionType })).sorted(by: {$0.order < $1.order})
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
                                .font(.caption2)
                                .padding(4)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(reactionType.highlightColour))
                                .foregroundStyle(.white)
                                .padding(.trailing, -14)
                        }
                        Text("\(viewModel.reactions.count)")
                            .foregroundStyle(.secondary)
                            .padding(.leading, 10)
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
            
            ZStack {
                HStack {
                    ReactionView(selection: $editReactionType)
                        .padding(.leading)
                        .onChange(of: editReactionType) {
                            Task {
                                do {
                                    try await viewModel.selectedReaction(editReactionType)
                                } catch {
                                    ErrorLogger.shared.log(error)
                                }
                            }
                        }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .padding(.trailing)
                    .onTapGesture {
                        self.showComments = true
                    }
                    
                }
                HStack {
                    Image(systemName: "bubble")
                    Text("Comment")
                }
                .padding(.trailing)
                .onTapGesture {
                    self.showComments = true
                }
            }
            .foregroundStyle(.secondary)
        }
        .sheet(isPresented: $showComments) {
            Text("Comments")
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReactions) {
            ReactionsSheetView(reactions: viewModel.reactions)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                do {
                    viewModel.setContext(ViewModelContext(uid: auth.user.uid, username: auth.user.username, source: self.source, sourceId: self.sourceId))
                    try await viewModel.loadComments()
                    try await viewModel.loadReactions()
                    editReactionType = viewModel.currentReaction.reactionType
                } catch {
                    ErrorLogger.shared.log(error)
                }
            }
        }
    }
}

#Preview {
    CommentStripView(source: .journal, sourceId: "1", viewModel: CommentStripView.ViewModel(commentService: CommentService.Mock(), reactionService: ReactionService.Mock(sampleData: true)))
            .environmentObject(AuthenticationManager.forPreview(metric: false))
}
