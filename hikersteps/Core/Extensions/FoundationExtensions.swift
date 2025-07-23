//
//  Extensions.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 17/07/2025.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Date {
    func asDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMM yyyy"
        return dateFormatter.string(from: self)
    }
}

