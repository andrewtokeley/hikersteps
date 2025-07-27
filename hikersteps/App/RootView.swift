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
            case .loading:
                LoadingView()
            case .authenticated, .loadingComplete, .unauthenticated:
                HomeView()
            }
        }
        .environmentObject(appState)
    }
}

#Preview {
    return RootView()
}
