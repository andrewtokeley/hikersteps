//
//  Date.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 06/09/2025.
//

import Foundation

import Foundation

extension Date {
    func localisedTimeAgoDescription() -> String {
        let now = Date()
        let seconds = now.timeIntervalSince(self)
        
        // Special case: "Just now" for < 60s
        if seconds < 60 {
            return NSLocalizedString("Just now", comment: "Shown when less than 1 minute ago")
        }
        
        // Use system formatter
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full   // or .short for "5 min ago"
        
        // If older than a year, show absolute date instead
        if let yearDiff = Calendar.current.dateComponents([.year], from: self, to: now).year,
           yearDiff >= 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            return dateFormatter.string(from: self)
        }
        
        return formatter.localizedString(for: self, relativeTo: now)
    }
}
