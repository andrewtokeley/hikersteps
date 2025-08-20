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
    func asDateString(withYear: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        if withYear {
            dateFormatter.dateFormat = "EEEE d MMM yyyy"
        } else {
            dateFormatter.dateFormat = "EEEE d MMM"
        }
        return dateFormatter.string(from: self)
    }
}

