//
//  CapsuleButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 10/07/2025.
//

import SwiftUI

extension Button {
    func capsuleStyled(background: Color = .blue, foreground: Color = .white) -> some View {
        self
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(background)
            .foregroundColor(foreground)
            .clipShape(Capsule())
    }
}
