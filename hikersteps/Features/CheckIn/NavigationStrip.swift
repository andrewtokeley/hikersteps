//
//  NavigationStrip.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/07/2025.
//

import SwiftUI

struct NavigationStripView<Content: View>: View {
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)?
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            AppCircleButton(imageSystemName: "arrow.left.to.line")
                .style(foreground: Color(.appButtonForeground), background: .white, border: false)
                .onClick { onNavigate?(.start) }
            AppCircleButton(size: 40, imageSystemName: "arrow.left")
                .onClick { onNavigate?(.previous) }
            Spacer()
            content
            Spacer()
            AppCircleButton(size: 40, imageSystemName: "arrow.right")
                .onClick { onNavigate?(.next) }
            AppCircleButton(imageSystemName: "arrow.right.to.line")
                .style(foreground: Color(.appButtonForeground), background: .white, border: false)
                .onClick { onNavigate?(.end) }
        }
    }
    
    func onNavigate(_ handler: @escaping (_ direction: NavigationDirection) -> Void) -> NavigationStripView {
        var copy = self
        copy.onNavigate = handler
        return copy
    }
}

#Preview {
    NavigationStripView() {
        Text("My Title")
    }
}
