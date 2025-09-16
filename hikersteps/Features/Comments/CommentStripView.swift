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
    
    // Rect that describes the item that initiated the popover
    @State private var targetFrame: CGRect = .zero
    
    @State private var showComments: Bool = false
    @State private var showReactions: Bool = false
    @State private var showReactionSelector: Bool = false
    
    /**
     Local store of selected reaction - we hold here rather than binding directly to viewmodel so that the viewModel can update firestore based on any changes to this.
     */
    @State private var editReactionType: ReactionType = ReactionType.none
    
    var socialContext: SocialContext
    
    var uniqueReactionTypes: [ReactionType] {
        return Array(Set(viewModel.reactions.map { $0.reactionType })).sorted(by: {$0.order < $1.order})
    }
    
    init(socialContext: SocialContext, viewModel: ViewModel) {
        self.socialContext = socialContext
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init(socialContext: SocialContext) {
        self.init(socialContext: socialContext, viewModel: ViewModel(commentService: SocialService()))
    }
    
    var body: some View {
        NavigationStack {
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
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .padding(.trailing)
                        .onTapGesture {
                            //                        Task {
                            //                            let options = ShareOptions(
                            //                                viewportCentre: .checkIn,
                            //                                zoomLevel: 10,
                            //                                isShare: true)
                            //                            let share = await ShareActivities.createForJournal(username: auth.user.username, journalId: SocialContext., checkIn: checkIn, shareOptions: options)
                            //                            self.shareItems = share.items
                            //                            self.showShareView = true
                            //                                    }
                        }
                    }
                    HStack {
                        Image(systemName: "bubble")
                        Text("Comment")
                    }
                    .onTapGesture {
                        self.showComments = true
                    }
                }
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showComments) {
            CommentsSheetView(comments: $viewModel.comments, context: socialContext)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReactions) {
            ReactionsSheetView(reactions: viewModel.reactions)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        
        .onAppear {
            Task {
                do {
                    viewModel.setContext(self.socialContext)
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
    CommentStripView(socialContext: SocialContext(source: .journal, sourceId: "1", auth: AuthenticationManager.forPreview()), viewModel: CommentStripView.ViewModel(commentService: SocialService.Mock()))
            .environmentObject(AuthenticationManager.forPreview(metric: false))
}
