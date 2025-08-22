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
    @State private var message: String = "loading..."
    
    var userService: UserServiceProtocol
    var userSettingsService: UserSettingsServiceProtocol
    
    /**
     Main initialiser
     */
    init() {
        self.userService = UserService()
        self.userSettingsService = UserSettingsService()
    }
    
    /**
     Used to inject mock services to the view
     */
    init(userService: UserServiceProtocol, userSettingsService: UserSettingsServiceProtocol) {
        self.userService = userService
        self.userSettingsService = userSettingsService
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
        .task {
            await loadData()
        }
    }
    
    func setLoadingMessage(_ message: String) {
        self.message = message
    }
    
    func loadData() async {
        
        // Simulate loading
        do {
            if auth.isLoggedIn {
                try await auth.loadUserAndSettings()
            }
            
            // This will navigate us to the next view
            await MainActor.run {
                appState.phase = .loadingComplete
            }
            
        } catch {
            ErrorLogger.shared.log(error)
        }
    }
}

#Preview {
    LoadingView(userService: UserService.Mock(), userSettingsService: UserSettingsService.Mock())
        .environmentObject(AppState())
        .environmentObject(AuthenticationManager(
            authProvider: AuthProviderMock(),
            userService: UserService.Mock(),
            userSettingsService: UserSettingsService.Mock()))
}
