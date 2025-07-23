//
//  LoginView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var auth: AuthenticationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome")
                .font(.largeTitle)
            
            GoogleSignInButton {
                Task {
                    await auth.handleSignIn()
                    appState.phase = .authenticated
                }
            }
            .frame(height: 50)
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
