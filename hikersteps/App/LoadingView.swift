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

    var body: some View {
        ZStack {
            Color(.appPrimary)
                .ignoresSafeArea()
            
            VStack {
                Image(systemName: "mappin.and.ellipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.accentColor)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                            scale = scale == 1.0 ? 1.2 : 1.0
                        }
                        
                        Task {
                            await loadData()
                        }
                    }
                Text(message)
                    .padding()
                    .foregroundColor(.accentColor)
                }
        }
    }
    
    @MainActor
    func setLoadingMessage(_ message: String) {
        self.message = message
    }
    
    func loadData() async {
        
        // Simulate loading
        
        // Will be a different level of leading if the user is logged in
        setLoadingMessage("core data...")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        if auth.isLoggedIn {
            setLoadingMessage("user data...")
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
        
        await MainActor.run {
            appState.phase = .loadingComplete
        }
    }
//    @MainActor
//    func animate() {
//        guard isAnimating else { return }
//
//        withAnimation(.easeInOut(duration: 0.6)) {
//            scale = scale == 1.0 ? 1.2 : 1.0
//        }
//        
//        // Schedule next animation frame
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            animate()
//        }
//    }
    
//    func loadData() async {
//        // kick off animation
//        print("Start...")
//        animate()
//        
//        Task {
//            // do some pre-launch operations - data loading etc.
//            try? await Task.sleep(nanoseconds: 5_000_000_000) // 2 seconds
//            
//            await MainActor.run {
//                appState.phase = .loadingComplete
//                isAnimating = false
//                print("Stop.")
//            }
//        }
//        
//    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    mock.isLoggedIn = true
    return LoadingView()
        .environmentObject(AppState())
        .environmentObject(mock)
}
