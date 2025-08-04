//
//  ViewStyleExtensions.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 19/07/2025.
//

import Foundation
import SwiftUI

extension Color {
    
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

extension View {
    
    /**
     Adds a light coloured rounded border around the view.
     */
    func styleBorderLight(focused: Bool = false) -> some View {
        let colour = focused ? Color.accentColor : Color.gray
        return self
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(colour.opacity(0.4), lineWidth: 1)
            )
    }
    
//    func styleForegroundPrimary() -> some View {
//        self
//            .foregroundStyle(Color("appPrimary"))
//    }
    
}
