//
//  ReactionView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/09/2025.
//

import SwiftUI

/**
 View binds to a reaction (love, fire, like...) and optionally a label. If tapped the visible reaction is either selected or deselected. And if LongPressed it allows a new reaction to be selected from a fullscreen display.
 */
struct ReactionView: View {
    
    @Binding var selection: ReactionType
    @State private var showReactionSelector: Bool = false
    @State private var visibleReactionType = ReactionType.like
    @State private var yOffSet: CGFloat
    @State private var frame: CGRect
    @State private var disableTap: Bool = false
    @State private var dragLocation: CGPoint = .zero
    
    init(selection: Binding<ReactionType>, yOffSet: CGFloat = 0, frame: CGRect = .zero) {
        _selection = selection
        self.yOffSet = yOffSet
        self.frame = frame
    }
    
    var showLabel: Bool = true
    var onLongPressGesture: ((CGRect) -> Void)?
    
    var body: some View {
        
        HStack {
            Group {
                if selection == .none {
                    Image(systemName: visibleReactionType.systemImageName)
                } else {
                    Image(systemName: selection.systemImageNameFilled)
                        .foregroundStyle(selection.highlightColour)
                }
                if (showLabel) {
                    Text(selection == .none ? visibleReactionType.title : selection.title)
                }
            }
            .foregroundColor(.secondary)
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        frame = geo.frame(in: .global)
                    }
                    .onChange(of: geo.frame(in: .global)) { old, newFrame in
                        frame = newFrame
                    }
            })
        .gesture( TapGesture()
            .onEnded {_ in
                if !disableTap {
                    print("tap end")
                    if self.selection == .none {
                        self.selection = visibleReactionType
                    } else {
                        self.selection = .none
                    }
                }
            })
        .highPriorityGesture(LongPressGesture(minimumDuration: 0.4)
            .onEnded { _ in
                print("long press end")
                disableTap = true
                self.yOffSet = self.frame.origin.y
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withoutAnimation{
                    showReactionSelector = true
                    disableTap = false
                }
            }
        )
        .fullScreenCover(isPresented: $showReactionSelector) {
            ReactionSelectorView(selection: $selection, yOffSet: $yOffSet, dragLocation: $dragLocation)
                .presentationBackground(.clear)
                .interactiveDismissDisabled(false)
                .onChange(of: selection) {
                    withoutAnimation{
                        showReactionSelector = false
//                        disableTap = false
                    }
                }
        }
        
    }
    
    func onLongPressGesture(_ handler: ((CGRect) -> Void)?) -> ReactionView {
        var copy = self
        copy.onLongPressGesture = handler
        return copy
    }
    
}

#Preview {
    @Previewable @State var reactionType:ReactionType = .fire
    ReactionView(selection: $reactionType)
}
