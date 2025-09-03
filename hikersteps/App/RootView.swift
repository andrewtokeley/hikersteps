//
//  RootView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            switch appState.phase {
            case .starting, .successfulLogin:
                // essentially a holding screen until Firebase Auth catches up
                LoadingView(authenticated: false)
            case .unauthenticated:
                LoginView()
            case .authenticated:
                LoadingView(authenticated: true)
            case .loadingComplete:
                MainView()
            case .crash(let details):
                CrashReport(details)
            }
        }
        .environmentObject(appState)
    }
}

#Preview {
    return RootView()
}
