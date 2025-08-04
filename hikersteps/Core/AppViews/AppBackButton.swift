//
//  AppBackButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 26/07/2025.
//

import SwiftUI

struct AppBackButton: View {
    @Environment(\.dismiss) private var dismiss
    private var willDismiss: (() -> Void)? = nil
    
    var size: Double = 30
    
    var body: some View {
        
        AppCircleButton(imageSystemName: "arrow.backward")
            .style(.filledOnImage)
            .onClick {
                willDismiss?()
                dismiss()
            }
    }
    
    func willDismiss(_ handler: @escaping (() -> Void)) -> AppBackButton {
        var copy = self
        copy.willDismiss = handler
        return copy
    }
}

#Preview {
    AppBackButton()
}
