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
                    let result = await auth.handleSignIn()
                    if result {
                        await MainActor.run {
                            appState.phase = .successfulLogin
                        }
                    } else {
                        // display message?
                    }
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
