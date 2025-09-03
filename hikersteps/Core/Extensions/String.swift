//
//  String.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 28/08/2025.
//

import Foundation

extension String {
    /**
     Returns a new string after trimming any characters that existing beyond the given character index.
     */
    func trimCharacters(from index: Int, showEllipsis: Bool = true) -> String {
        if self.count <= index {
            return self
        }
        
        // Take the first 100 characters
        let index = self.index(self.startIndex, offsetBy: index)
        var substring = String(self[..<index])
        
        // Remove trailing spaces
        substring = substring.trimmingCharacters(in: .whitespaces)
        
        return substring + (showEllipsis ? "..." : "")
    }
}
