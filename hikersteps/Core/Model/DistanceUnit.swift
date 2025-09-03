////
////  DistanceUnit.swift
////  hikersteps
////
////  Created by Andrew Tokeley on 24/08/2025.
////
//
//import Foundation
//
//enum UnitDistance {
//    case km
//    case mi
//    
//    var unitLength: UnitLength {
//        switch self {
//        case .km:
//            return .kilometers
//        case .mi:
//            return .miles
//        }
//    }
//    
//    var properName: String {
//        switch self {
//        case .km:
//            return "kilometers"
//        case .mi:
//            return "miles"
//        }
//    }
//    
//    static func from(unitLength: UnitLength) -> UnitDistance {
//        switch unitLength {
//        case .kilometers:
//            return .km
//        case .miles:
//            return .mi
//        default: return .km
//        }
//    }
//}
//
//struct DistanceUnit {
//    
//    var measurement: Measurement<UnitLength>
//    
//    var number: Int { Int(measurement.value) }
//    var unit: UnitDistance { UnitDistance.from(unitLength: measurement.unit) }
//    
//    init(_ number: Int, _ unit: UnitDistance ) {
//        self.measurement = Measurement(value: Double(number), unit: unit.unitLength)
//    }
//    
//    func convertTo(_ to: UnitDistance) -> DistanceUnit {
//        let result = self.measurement.converted(to: to.unitLength)
//        return .init(Int(result.value), UnitDistance.from(unitLength: result.unit))
//    }
//    
//    static func zero(_ unit: UnitDistance) -> DistanceUnit {
//        return DistanceUnit(0, unit)
//    }
//    
//    static func == (lhs: DistanceUnit, rhs: DistanceUnit) -> Bool {
//        return lhs.measurement == rhs.measurement
//    }
//    
//    static func != (lhs: DistanceUnit, rhs: DistanceUnit) -> Bool {
//        return lhs.measurement != rhs.measurement
//    }
//    
//    static func + (lhs: DistanceUnit, rhs: DistanceUnit) -> DistanceUnit {
//        let result = lhs.measurement + rhs.measurement
//        return .init(Int(result.value), UnitDistance.from(unitLength: result.unit))
//    }
//    
//    static func - (lhs: DistanceUnit, rhs: DistanceUnit) -> DistanceUnit {
//        let result = lhs.measurement - rhs.measurement
//        return .init(Int(result.value), UnitDistance.from(unitLength: result.unit))
//    }
//    
//}
