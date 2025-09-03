//
//  SplashView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var auth: AuthenticationManager
    
    @State private var scale: CGFloat = 1.0
    @State private var message: String
    @State private var authenticated: Bool
    
    var userService: UserServiceProtocol
    var userSettingsService: UserSettingsServiceProtocol
    
    /**
     Main initialiser
     */
    init(authenticated: Bool) {
        self.init(authenticated: authenticated, userService: UserService(), userSettingsService: UserSettingsService())
    }
    
    /**
     Used to inject mock services to the view
     */
    init(authenticated: Bool, userService: UserServiceProtocol, userSettingsService: UserSettingsServiceProtocol) {
        self.userService = userService
        self.userSettingsService = userSettingsService
        self.authenticated = authenticated
        self.message = authenticated ? "loading..." : "logging in..."
    }
    
    var body: some View {
        ZStack {
            Color(.appPrimary)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(.appOrange))
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            scale = scale == 1.0 ? 1.2 : 1.0
                        }
                    }
                Text(message)
                    .padding()
                    .foregroundColor(Color(.appOrange))
                }
        }
        .onAppear {
            Task {
                if authenticated {
                    await loadData()
                }
            }
        }
    }
    
    func setLoadingMessage(_ message: String) {
        self.message = message
    }
    
    func loadData() async {
        do {
            try await auth.loadUserAndSettings()
            appState.phase = .loadingComplete
        } catch {
            ErrorLogger.shared.log(error)
            appState.phase = .crash("Can't load user data. Try again.")
        }
    }
}

#Preview {
    LoadingView(authenticated: false, userService: UserService.Mock(), userSettingsService: UserSettingsService.Mock())
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager.forPreview())
}
