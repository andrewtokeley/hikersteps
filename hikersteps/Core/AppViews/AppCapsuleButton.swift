//
//  AppCapsuleButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 07/08/2025.
//

import SwiftUI

enum CapsuleButtonStyle {
    case filled
    case white
}

struct AppCapsuleButton: View {
    
    var capsuleStyle: CapsuleButtonStyle = .filled
    var text: String = ""
    var action: (() -> Void)?
    var width: CGFloat? = nil
    
    private var _style: ( foreground: Color, background: Color, border: Bool ) {
        switch capsuleStyle {
        case .filled:
            return (
                foreground: Color(.white),
                background: .accentColor,
                border: false)
        case .white:
            return (
                foreground: .black,
                background: .white,
                border: true)
        }
    }
    
    init(_ text: String, width: CGFloat? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
        self.width = width
    }
    var body: some View {
        Button(text) {
            action?()
        }
        .frame(width: self.width)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(_style.background)
        .foregroundColor(_style.foreground)
        .clipShape(Capsule())
        .overlay(
            Group {
                if _style.border {
                    Capsule()
                        .stroke(Color.gray, lineWidth: 2)
                }
            }
        )
        
    }
    
    func capsuleStyle(_ style: CapsuleButtonStyle) -> some View {
        var copy = self
        copy.capsuleStyle = style
        return copy
    }
    
}

#Preview {
    HStack {
        AppCapsuleButton("Continue", width: 100) {
            print("continue...")
        }
        .capsuleStyle(.filled)
        
        AppCapsuleButton("Cancel")
            .capsuleStyle(.white)
    }
}
