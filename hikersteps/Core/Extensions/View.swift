//
//  View.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 08/09/2025.
//

import Foundation
import SwiftUI

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
