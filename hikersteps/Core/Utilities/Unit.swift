//
//  NumberUnit.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import Foundation

/**
 Represents a unit that qualifies what type of number is being represented
 */
enum Unit: String, Identifiable {
    var id: String { self.rawValue }
    
    case km = "km"
    case mi = "mi"
    case days = "days"
    case weeks = "weeks"
    
    var properName: String {
    switch self {
    case .km: "Kilometres"
    case .mi: "Miles"
    case .days: "Days"
    case .weeks: "Weeks"
    }
    }
}

class NumberUnit {
    var number: Double
    var unit: Unit
    
    init(number: Double, unit: Unit) throws {
        self.number = number
        self.unit = unit
    }
    
    internal enum Errors: Error, Equatable {
        case illegalConversion
        case illegalUnit
    }
}

class DistanceUnit: NumberUnit {
    override init(number: Double, unit: Unit) throws {
        guard unit == .km || unit == .mi else {
            throw(Errors.illegalUnit)
        }
        try super.init(number: number, unit: unit)
    }
    
    func convert(to: Unit) -> DistanceUnit {
        guard unit == .km || unit == .mi else {
            // can't convert km/mi to anything alse
            return self
        }
        
        if (unit == .km && to == .mi) {
            let miles = number * 0.621371
            return try! DistanceUnit(number: miles , unit: .mi)
        } else if (unit == .mi && to == .km) {
            let km = number * 1.60934
            return try! DistanceUnit(number: km , unit: .km)
        } else {
            // asking to convert km to km, or mi to mi
            return self
        }
    }
}
