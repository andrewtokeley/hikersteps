//
//  AppCircleButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/07/2025.
//

import SwiftUI

enum CircleButtonStyle {
    case filled
    case filledOnImage
    case plain
    case white
}

/**
 Circular button that surrounds a SF Symobl and is fully dark/light mode compatible
 */
struct AppCircleButton: View {
    
    var size: Double
    var bottonNudge: CGFloat = 0
    var imageSystemName: String
    var style: CircleButtonStyle = .filled
    var rotationAngle: Angle = .degrees(0)
    
    private var _style: ( foreground: Color, background: Color, border: Bool ) {
        switch style {
        case .filled:
            return (
                foreground: Color.adaptive(light: .black, dark: .white),
                background: Color.adaptive(light: Color(.systemGray5), dark: Color(.appDarkGray)),
                border: false)
        case .filledOnImage:
            return (
                foreground: Color.adaptive(light: .black, dark: .white),
                background: Color.adaptive(light: .white, dark: Color(.systemGray2).opacity(0.8)),
                border: false)
        case .plain:
            return (
                foreground: Color.adaptive(light: Color(.appPrimary), dark: .white),
                background: Color(.clear),
                border: false)
        case .white:
            return (
                foreground: .black,
                background: .white,
                border: false)
        }
    }
    private var onClick: (() -> Void)?
    
    init(size: Double = 30, imageSystemName: String = "arrow.left.to.line", style: CircleButtonStyle = .filled, rotationAngle: Angle = .degrees(0), bottomNudge: CGFloat = 0, onClick: (() -> Void)? = nil) {
        
        self.size = size
        self.imageSystemName = imageSystemName
        self.onClick = onClick
        self.style = style
        self.rotationAngle = rotationAngle
        self.bottonNudge = bottomNudge
    }
    
    var body: some View {
        if onClick != nil {
            Button(action: {
                onClick?()
            }) {
                image
            }
            .buttonStyle(PlainButtonStyle()) // Prevents default button styling if you want
        } else {
            image
        }
    }

    private var image: some View {
        Image(systemName: imageSystemName)
            .foregroundColor(_style.foreground)
            .font(.system(size: 0.6 * size, weight: .light))
            .frame(width: size, height: size)
            .padding(.all, 4)
            .padding(.bottom, bottonNudge)
            .background(Circle().fill(_style.background))
            .overlay(
                RoundedRectangle(cornerRadius: size / 2)
                    .strokeBorder(_style.border ? Color(_style.foreground) : Color(.clear), lineWidth: 1)
            )
            .rotationEffect(rotationAngle)
    }
    
    func onClick(_ handler:(() -> Void)?) -> AppCircleButton {
        var copy = self
        copy.onClick = handler
        return copy
    }
    
    func style(_ style: CircleButtonStyle) -> AppCircleButton {
        var copy = self
        copy.style = style
        return copy
    }
}

#Preview {
    VStack {
        AppCircleButton(imageSystemName: "arrow.left")
            .style(.filledOnImage)
            
        HStack {
            AppCircleButton(imageSystemName: "arrow.left.to.line")
                .style(.plain)
            AppCircleButton(imageSystemName: "arrow.left")
            Spacer()
            AppCircleButton(imageSystemName: "arrow.right")
            AppCircleButton(imageSystemName: "arrow.right.to.line")
                .style(.plain)
        }
        .padding()
    }
    
}
