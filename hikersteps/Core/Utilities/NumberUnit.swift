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
        self == .kg || self == .lbs
    }
}

enum NumberUnitErrors: Error, Equatable {
    case illegalConversion
    case illegalUnit
    case unitMismatch
}

protocol NumberUnitProtocol {
    var description: String { get }
}

class NumberUnit<T>: Codable, NumberUnitProtocol where T: Numeric, T: Codable, T: CVarArg {
    
    var number: T = 0
    var unit: Unit = .none
    
    // MARK: - Enable Firestore retrieval
    
    enum CodingKeys: String, CodingKey {
        case number
        case unit
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.number = try container.decodeIfPresent(T.self, forKey: .number) ?? 0
        self.unit = try container.decodeIfPresent(Unit.self, forKey: .unit) ?? .none
    }
    
    
    required init(_ number: T, _ unit: Unit) {
        self.number = number
        self.unit = unit
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
    
    
//    static func == (lhs: NumberUnit<T>, rhs: NumberUnit<T>) -> Bool {
//        return lhs.number == rhs.number && lhs.unit == rhs.unit
//    }
//    
//    static func + (lhs: NumberUnit<T>, rhs: NumberUnit<T>) -> NumberUnit<T> {
//        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
//        return .init(lhs.number + rhs.number, lhs.unit)
//    }
//    
//    static func - (lhs: NumberUnit<T>, rhs: NumberUnit<T>) -> NumberUnit<T>  {
//        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
//        return .init(lhs.number - rhs.number, lhs.unit)
//    }
//    
//    static func += (lhs: inout NumberUnit<T>, rhs: NumberUnit<T>) {
//        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
//        lhs.number += rhs.number
//    }
//    
//    static func -= (lhs: inout NumberUnit<T>, rhs: NumberUnit<T>) {
//        guard lhs.unit == rhs.unit else { fatalError("Mismatched Units") }
//        lhs.number -= rhs.number
//    }
    
}

class DistanceUnit: NumberUnit<Int> {
    
    /**
     Creates a new distance unit.
     
     - Parameters:
        - number: Integer value for the distance
        - unit: either .km or .mi. If another unit is supplied it will be converted to .km
     */
    required init(_ number: Int, _ unit: Unit) {
        super.init(number, unit.isDistance ? unit : .km)
    }
    
    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
    }
    
    func convertTo(_ to: Unit) -> DistanceUnit {
        
        if unit == to {
            return self
        }
        
        switch (unit, to) {
        case (.km, .mi):
            return DistanceUnit(Int(Double(number) * 0.621371), to)
        case (.mi, .km):
            return DistanceUnit(Int(Double(number) * 1.60934), to)
        default:
            // can't convert to anything else, just return self unchanged
            return self
        }
    }
}

class WeightUnit: NumberUnit<Double> {
    
    /**
     Creates a new weight unit.
     
     - Parameters:
     - number: Double value for the weight
     - unit: a weight unit. If not a weight unit it will be assumed to be .kg
     */
    required init(_ number: Double, _ unit: Unit) {
        super.init(number, unit.isWeight ? unit : .kg)
    }
    
    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
    }
    
    func convertTo(_ to: Unit) -> WeightUnit {
        
        if unit == to {
            return self
        }
        
        switch (unit, to) {
        case (.km, .mi):
            return WeightUnit(number * 0.621371, to)
        case (.mi, .km):
            return WeightUnit(number * 1.60934, to)
        default:
            // can't convert to anything else, just return self unchanged
            return self
        }
    }
}

func += <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: inout U, rhs: U) {
    precondition(lhs.unit == rhs.unit, "Mismatched Units")
    lhs.number += rhs.number
}

func -= <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: inout U, rhs: U) {
    precondition(lhs.unit == rhs.unit, "Mismatched Units")
    lhs.number -= rhs.number
}

func + <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: U, rhs: U) -> U {
    precondition(lhs.unit == rhs.unit, "Mismatched Units")
    return U(lhs.number + rhs.number, lhs.unit)
}

func - <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: U, rhs: U) -> U {
    precondition(lhs.unit == rhs.unit, "Mismatched Units")
    return U(lhs.number - rhs.number, lhs.unit)
}

func == <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: U, rhs: U) -> Bool {
    lhs.number == rhs.number && lhs.unit == rhs.unit
}

func != <T: Numeric & Codable & CVarArg, U: NumberUnit<T>>(lhs: U, rhs: U) -> Bool {
    !(lhs == rhs)
}
