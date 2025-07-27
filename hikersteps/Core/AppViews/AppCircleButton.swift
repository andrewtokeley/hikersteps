//
//  AppCircleButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/07/2025.
//

import SwiftUI

struct AppCircleButton: View {
    var size: Double
    var imageSystemName: String
    
    private var style: ( foreground: Color, background: Color, border: Bool )
    private var onClick: (() -> Void)?
    
    init(size: Double = 30, imageSystemName: String = "arrow.left.to.line", style: ( foreground: Color, background: Color, border: Bool ) = (foreground: Color(.appButtonForeground), background: Color(.appButtonBackground), border: true),  onClick: (() -> Void)? = nil) {
        
        self.size = size
        self.imageSystemName = imageSystemName
        self.onClick = onClick
        self.style = style
    }
    
    var body: some View {
        Button(action: {
            onClick?()
        }) {
            Image(systemName: imageSystemName)
                .foregroundColor(style.foreground)
                .font(.system(size: 0.6 * size, weight: .medium))
                .frame(width: size, height: size)
                .background(Circle().fill(style.background))
                .overlay(
                    RoundedRectangle(cornerRadius: size / 2)
                        .strokeBorder(style.border ? Color(.appButtonForeground) : Color(.clear), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling if you want
    }
    
    func onClick(_ handler:(() -> Void)?) -> AppCircleButton {
        var copy = self
        copy.onClick = handler
        return copy
    }
    func style(foreground: Color, background: Color, border: Bool = true) -> AppCircleButton {
        var copy = self
        copy.style = (foreground: foreground, background: background, border: border)
        return copy
    }
}

#Preview {
    HStack {
        AppCircleButton(imageSystemName: "arrow.left.to.line")
            .style(foreground: Color(.appButtonForeground), background: .white, border: false)
        AppCircleButton(size: 40, imageSystemName: "arrow.left")
        Spacer()
        AppCircleButton(size: 40, imageSystemName: "arrow.right")
        AppCircleButton(imageSystemName: "arrow.right.to.line")
            .style(foreground: Color(.appButtonForeground), background: .white, border: false)
    }
    .padding()
}
