//
//  AppState.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import SwiftUI
import FirebaseAuth

enum AppPhase {
    /// phase is entered whenever a user logs out
    case unauthenticated
    /// phase is entered whenever a user successfully signs in
    case authenticated
    // Show LoadingView straight after LaunchScreen and load application data
    case loading
    // Once application data is loaded we show the HomeView
    case loadingComplete
}

@MainActor
class AppState: ObservableObject {
    @Published var phase: AppPhase = .loading
    
    init() {
        let _ = Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                self.phase = .unauthenticated
            }
        }
    }
}
