//
//  ReactionView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/09/2025.
//

import SwiftUI

struct ReactionView: View {
    
    @Binding var selection: ReactionType
    @State private var showReactions: Bool = false
    @State private var visibleReactionType = ReactionType.like
    
    var body: some View {
        HStack {
            Group {
                if selection == .none {
                    Image(systemName: visibleReactionType.systemImageName)
                } else {
                    Image(systemName: selection.systemImageNameFilled)
                        .foregroundStyle(selection.highlightColour)
                }
                
                Text(selection == .none ? visibleReactionType.title : selection.title)
            }
            .foregroundColor(.secondary)
            .onLongPressGesture {
                self.showReactions = true
            }
            .onTapGesture {
                if self.selection == .none {
                    self.selection = visibleReactionType
                } else {
                    self.selection = .none
                }
            }
        }
        .fullScreenCover(isPresented: $showReactions) {
            ZStack {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                
                HStack (spacing: 5) {
                    ForEach(ReactionType.all) { r in
                        VStack {
                            
                            Image(systemName: r.systemImageNameFilled)
                                .foregroundColor(r.highlightColour)
                                .padding(10)
                                .background(Circle().fill(r == self.selection ? Color(.appLightGray) : .clear))
                        }
                        .frame(width: 60,height: 40)
                        .onTapGesture {
                            if r == self.selection {
                                self.selection = .none
                            } else {
                                self.selection = r
                            }
                            self.visibleReactionType = r
                            self.showReactions = false
                        }
                    }
                }
                .padding()
                .background(.white)
                .frame(height:50)
                .cornerRadius(25)
                .shadow(radius: 3)
            }
            .onTapGesture {
                self.showReactions = false
            }
        }
        

    }
}

#Preview {
    @Previewable @State var reactionType:ReactionType = .fire
    ReactionView(selection: $reactionType)
}
