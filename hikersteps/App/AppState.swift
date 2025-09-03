//
//  AppState.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import SwiftUI
import FirebaseAuth

enum AppPhase {
    /// phase is entered when the app first loads and shows a blank view
    case starting
   
    /// phase is entered if the user opens the app and is not logged in. It will cause RootView to show the LoginView
    case unauthenticated
    
    /// phase is entered after use successfully logs in but before Firebase auth has change status. When set returns to holding view
    case successfulLogin
    
    /// phase is entered when Firebase successfull authenticates user after they've logged in. When set, it will cause the RootView to show the LoadingView
    case authenticated
    
    /// phase is entered after the LoadView has finished initialising the app. It will cause the RootView to show the HomeView
    case loadingComplete
    
    /// phase is entered when something unexpected happens and we want to have a softer landing to share something with the user.
    case crash(String)
}

@MainActor
class AppState: ObservableObject {
    /// Defaults to starting
    @Published var phase: AppPhase = .starting
    
    var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { auth, user in
            print("AppState: addStateDidChangeListener")
            if user == nil {
                print("AppState: unauthenticated")
                self.phase = .unauthenticated
            } else {
                print("AppState: authenticated")
                self.phase = .authenticated
            }
        }
    }

    deinit {
        if let handler = self.handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
}
