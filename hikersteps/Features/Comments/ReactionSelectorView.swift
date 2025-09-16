//
//  ReactionSelector.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/09/2025.
//

import SwiftUI

struct ReactionSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: ReactionType
    @Binding var yOffSet: CGFloat
    
    @State private var hoverReaction: ReactionType
    
    @State private var reactionFrames: [CGRect]
    
    @Binding private var dragLocation: CGPoint
    
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 5
    private let reactionImageWidth: CGFloat = 60
    private var count: Int { ReactionType.all.count }
    private var leftEdgeOfCapsule: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return (
            screenWidth
            - 2.0 * padding
            - CGFloat(count) * reactionImageWidth
            - CGFloat(count - 1) * spacing)/2
    }
    
    init(selection: Binding<ReactionType>, yOffSet: Binding<CGFloat>, dragLocation: Binding<CGPoint> = .constant(.zero)) {
        _yOffSet = yOffSet
        _dragLocation = dragLocation
        _selection = selection
        _reactionFrames = State(initialValue: [])
        _hoverReaction = State(initialValue: .none)
    }
    
    var body: some View {
        ZStack {
            Color(.appLightGray).opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    withoutAnimation{
                        dismiss()
                    }
                }
            Spacer()
            
            HStack (spacing: spacing) {
                ForEach(ReactionType.all) { r in
                    
                    Image(systemName: r.systemImageNameFilled)
                        .frame(width: reactionImageWidth) //, height: 30)
                        .font(.system(size:22))
                        .scaleEffect((r == self.selection) ? 1.5 : 1.0)
                        .foregroundColor(r.highlightColour)
                        .padding(padding)
                        .onTapGesture {
                            handleSelection(r)
                        }
                }
            }
            .background(Color.adaptive(light: .white, dark: .black))
            .frame(height:50)
            .cornerRadius(25)
            .shadow(color: Color.adaptive(light: .gray, dark: .white), radius: 2, x:1, y:1)
            .position(x: UIScreen.main.bounds.width / 2, y: yOffSet - 150)
            
            HStack {
                ZStack {
                    Color(Color.adaptive(light: .white, dark: .black))
                        .onTapGesture {
                            handleSelection(nil)
                        }
                    Text("Select an emoji reaction")
                }
            }
            .frame(height: 90)
            .position(x: UIScreen.main.bounds.width / 2, y: yOffSet - 150 + 75)
        }
    }
    
    /**
     Assuming the first reaction starts at x = spacing, return the reaction at x. We'll offset x by the left hand x of the capsule background
     */
    func dragAlignedToReaction(_ reaction: ReactionType) -> Bool {
        return hoverReaction == reaction
    }
    
    func handleSelection(_ reaction: ReactionType?) {
        if let reaction = reaction {
            if reaction == self.selection {
                self.selection = .none
            } else {
                self.selection = reaction
            }
        } else {
            //self.selection = .none
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var selection: ReactionType = .like
    @Previewable @State var yOffSet: CGFloat = 50
    ReactionSelectorView(selection: $selection, yOffSet: $yOffSet)
}
