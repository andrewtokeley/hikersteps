//
//  CountryManager.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 14/08/2025.
//

import Foundation

struct Country: Identifiable {
    var id: String { return identifier }
    var identifier: String
    var countryName: String
    var flag: String
}

class CountryManager {
    
    private static var _countries: [Country] = []
    
    static var countries: [Country] {
        if _countries.isEmpty {
            _countries = Locale.Region.isoRegions
                .compactMap { code in
                    guard code.identifier
                        .count == 2 && code.identifier.uppercased().range(of: "^[A-Z]{2}$", options: .regularExpression) != nil else {
                        return nil
                    }
                    
                    if let name = Locale.current.localizedString(forRegionCode: code.identifier) {
                        return Country(
                            identifier: code.identifier,
                            countryName: name,
                            flag: CountryManager.flag(for: code.identifier))
                    }
                    return nil
                }
                .sorted(by: {$0.countryName < $1.countryName})
        }
        return _countries
    }

    static func country(for identifier: String) -> Country? {
        return countries.first{ $0.identifier == identifier }
    }
    
    private static func flag(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flag = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flag.unicodeScalars.append(scalarValue)
            }
        }
        return flag
    }
    
}
