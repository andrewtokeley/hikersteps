//
//  hikerstepsApp.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 26/06/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: FirebaseApp.app()?.options.clientID ?? ""
        )
        
        return true
    }
}

@main
struct hikerstepsApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
        .environmentObject(auth)
    }
}
