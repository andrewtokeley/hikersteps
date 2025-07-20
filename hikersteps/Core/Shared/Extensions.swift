//
//  Extensions.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 17/07/2025.
//

import Foundation
import SwiftUI

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


extension Date {
    func asDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMM yyyy"
        return dateFormatter.string(from: self)
    }
}

