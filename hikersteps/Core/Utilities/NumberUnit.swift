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
enum Unit: String, Codable, Identifiable, CaseIterable {
    case km, mi, days, weeks, kg, lbs, none
    
    var id: String { rawValue }
    
    var properName: String {
        switch self {
        case .km: return "Kilometres"
        case .mi: return "Miles"
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .kg: return "Kilograms"
        case .lbs: return "Pounds"
        case .none: return ""
        }
    }
    
    var isDistance: Bool {
        self == .km || self == .mi
    }
    var isWeight: Bool {
        self == .km || self == .mi
    }
}

enum NumberUnitErrors: Error, Equatable {
    case illegalConversion
    case illegalUnit
    case unitMismatch
}

protocol NumberUnitProtocol {
    var number: Double { get set }
    var unit: Unit { get }
    
    init(_ number: Double, _ unit: Unit)
    
    static func zero(_ unit: Unit) -> Self
    
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func += (lhs: inout Self, rhs: Self)
    static func -= (lhs: inout Self, rhs: Self)
    
    var description: String { get }
}

extension NumberUnitProtocol {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.number == rhs.number && lhs.unit == rhs.unit
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
        return .init(lhs.number + rhs.number, lhs.unit)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self  {
        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
        return .init(lhs.number - rhs.number, lhs.unit)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
        lhs.number += rhs.number
    }
    
    static func -= (lhs: inout Self, rhs: Self) {
        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
        lhs.number -= rhs.number
    }

    static func zero(_ unit: Unit) -> Self {
        return .init(0, unit)
    }

    var description: String {
        if unit == .days || unit == .weeks {
            return String(format: "%.0f", number) + unit.rawValue
        }
        return String(format: "%.1f", number) + unit.rawValue
    }
}

struct NumberUnit: NumberUnitProtocol, Codable {
    
    var number: Double = 0
    var unit: Unit = .none
    
    init(_ number: Double, _ unit: Unit) {
        self.number = number
        self.unit = unit
    }
    
    init<T: Numeric>(_ number: T, _ unit: Unit) {
        self.number = Double("\(number)") ?? 0
        self.unit = unit
    }
    
}

struct DistanceUnit: NumberUnitProtocol, Codable {
    var number: Double = 0
    var unit: Unit = .none
    
    init(_ number: Double, _ unit: Unit) {
        if !unit.isDistance {
            self.unit = .km
        } else {
            self.unit = unit
        }
        self.number = number
    }
    
    func convertTo(_ to: Unit) -> DistanceUnit {
        guard unit.isDistance && to.isDistance else { fatalError("Illegal Distance Unit \(unit)") }
        
        if unit == to {
            return self
        }
        
        let convertedValue: Double
        switch (unit, to) {
        case (.km, .mi):
            convertedValue = number * 0.621371
        case (.mi, .km):
            convertedValue = number * 1.60934
        default:
            convertedValue = number
        }
        
        return DistanceUnit(convertedValue, to)
    }
}

struct WeightUnit: NumberUnitProtocol, Codable {
    var number: Double = 0
    var unit: Unit = .none
    
    init(_ number: Double, _ unit: Unit) {
        if !unit.isWeight {
            self.unit = .kg
        } else {
            self.unit = unit
        }
        self.number = number
    }
    
    func convertTo(_ to: Unit) -> WeightUnit {
        guard unit.isWeight && to.isWeight else { fatalError("Illegal Weight Unit \(unit)") }
        
        if unit == to {
            return self
        }
        
        let convertedValue: Double
        switch (unit, to) {
        case (.km, .mi):
            convertedValue = number * 0.621371
        case (.mi, .km):
            convertedValue = number * 1.60934
        default:
            convertedValue = number
        }
        
        return WeightUnit(convertedValue, to)
    }
}


