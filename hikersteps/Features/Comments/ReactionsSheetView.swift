//
//  ReactionsSheetView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 04/09/2025.
//

import SwiftUI

struct ReactionsSheetView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    var reactions: [Reaction]
    
    @State private var typeFilter: ReactionType? = nil
    
    var uniqueReactionTypes: [ReactionType] {
        return Array(Set(reactions.map { $0.reactionType })).sorted(by: {$0.order < $1.order})
    }
    
    var singleReaction: Bool {
        return uniqueReactionTypes.count == 1
    }
    
    var filteredReactions: [Reaction] {
        if let typeFilter = self.typeFilter {
            return reactions.filter {$0.reactionType == typeFilter }
        } else {
            return reactions
        }
    }
    
    private func count(_ type: ReactionType? = nil) -> Int {
        if let type = type {
            return reactions.count(where: {$0.reactionType == type })
        }
        return reactions.count
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                if singleReaction {
                     
                } else {
                    Group {
                        Text("All")
                        Text("\(count())").padding(.trailing)
                    }
                    .onTapGesture {
                        self.typeFilter = nil
                    }
                }
                ForEach(uniqueReactionTypes) { type in
                    Group {
                        Image(systemName: type.systemImageNameFilled)
                            .padding(4)
                            .foregroundStyle(.white)
                            .background(Circle().fill(type.highlightColour))
                        Text("\(count(type))").padding(.trailing)
                    }.onTapGesture {
                        self.typeFilter = type
                    }
                }
            }
            .padding(.vertical)
            
            Divider()
        
            
            VStack(alignment: .leading) {
                ForEach(filteredReactions.indices, id: \.self) { index in
                    HStack {
                        ProfileImage(.small, username: filteredReactions[index].username)
                        Text(filteredReactions[index].username)
                        Spacer()
                        
                        Image(systemName: filteredReactions[index].reactionType.systemImageNameFilled)
                            .foregroundStyle(filteredReactions[index].reactionType.highlightColour)
                    }
                    Divider()
                }
            }
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    ReactionsSheetView(reactions: [
        Reaction(uid: "1", source: .checkIn, sourceId: "1", username: "tokes", reactionType: .fire),
        Reaction(uid: "2", source: .checkIn, sourceId: "1", username: "jenny", reactionType: .fire),
        Reaction(uid: "3", source: .checkIn, sourceId: "1", username: "skittles", reactionType: .like),
        Reaction(uid: "4", source: .checkIn, sourceId: "1", username: "gonzales", reactionType: .love),
    ])
    .environmentObject(AuthenticationManager.forPreview())
}
