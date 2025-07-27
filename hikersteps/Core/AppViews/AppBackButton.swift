//
//  AppBackButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 26/07/2025.
//

import SwiftUI

struct AppBackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var size: Double = 30
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "arrow.backward.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: size, weight: .medium))
                .frame(width: size, height: size)
                .background(Circle().fill(Color.black.opacity(0.7)))
                
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling if you want
    }
}

#Preview {
    AppBackButton()
}
