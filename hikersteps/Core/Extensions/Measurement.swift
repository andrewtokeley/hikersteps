//
//  Measurement.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 24/08/2025.
//

import Foundation

extension Measurement {
    func formatted(dp: Int, unitStyle: Formatter.UnitStyle = .medium) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = unitStyle
        formatter.numberFormatter.maximumFractionDigits = dp
        formatter.numberFormatter.minimumFractionDigits = dp
        return formatter.string(from: self)
    }
}
extension Dimension {
    
    /// Full localized unit name (e.g. "kilometers", "hours")
    var properName: String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .long
        // The value here doesn’t matter, we just want the unit’s name
        let measurement = Measurement(value: 2, unit: self)
        return formatter.string(from: measurement).replacingOccurrences(of: "2 ", with: "")
    }
}

