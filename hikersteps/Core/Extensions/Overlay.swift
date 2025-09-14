//
//  Overlay.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/09/2025.
//

import SwiftUI

extension View {
    /// Presents an overlay view conditionally, similar to `.sheet(isPresented:)`
    func overlay<Overlay: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                overlay()
                    .transition(.opacity)
                    .zIndex(1) // ensure it sits above
            }
        }
        .animation(.easeInOut, value: isPresented.wrappedValue)
    }
}
