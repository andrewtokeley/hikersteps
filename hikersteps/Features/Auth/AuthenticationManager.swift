//
//  AuthViewModel.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import UIKit

protocol AuthenticationManagerProtocol: ObservableObject {
    
    var isLoggedIn: Bool { get }
    
    /**
     Non optional settings so that we can bind to it directly in views
     */
    var userSettings: UserSettings { get set }
    
    /**
     Non optional user so that we can bind to it directly in views. If the user is not logged in User will return an empty instance with User.isAnonymous
     */
    var user: User { get set }
    
    func handleSignIn() async -> Bool
    
    /**
     Persist any changes to the User and UserSettings
     */
    func persistUserAndSettings() async throws
}

class AuthenticationManager: AuthenticationManagerProtocol {

    var isLoggedIn: Bool {
        return authProvider.isLoggedIn
    }
    
    var userSettings: UserSettings
    internal var userSettings_original: UserSettings
    
    var user: User
    internal var user_original: User
    
    internal var userService: UserServiceProtocol
    internal var userSettingsService: UserSettingsServiceProtocol
    internal var authProvider: AuthProviderProtocol
    
    required init(authProvider: AuthProviderProtocol, userService: UserServiceProtocol, userSettingsService: UserSettingsServiceProtocol) {
        
        self.authProvider = authProvider
        self.userService = userService
        self.userSettingsService = userSettingsService

        // default to anonymous until we log in
        user = User.anonymousUser
        user_original = user
        
        userSettings = UserSettings.defaultSettings()
        userSettings_original = userSettings
    }
    
    func loadUserAndSettings() async throws {
        try await loadUser()
        try await loadUserSettings()
    }
    
    @MainActor
    private func loadUser() async throws {
        guard authProvider.isLoggedIn else { return }
        
        var user: User?
        user = try await userService.getUser()
        
        //For users who have already got a user record...
        if let _ = user {
            // check if their profileUrl is uptodate
            if user!.profileUrl != authProvider.photoUrl {
                user!.profileUrl = authProvider.photoUrl
                try await userService.updateUser(user!)
            }
        } else {
            // This is the first time the user has signed in - create a User document in firestore
            if let uid = authProvider.uid, let displayName = authProvider.displayName {
                user = User(uid: uid, username: "", displayName: displayName, isActive: true)
                user?.profileUrl = authProvider.photoUrl
                let _ = try await userService.addUser(user!)
            } else {
                throw ServiceError.generalError("Can't add User - authProvider invalid")
            }
        }
        self.user = user!
        self.user_original = user!
    }
    
    private func loadUserSettings() async throws {
        print("loadUserSettings")
        var settings: UserSettings?
        settings = try await userSettingsService.getUserSettings()
        if settings == nil {
            // this is the first time the user has signed in - create some default settings for them
            settings = UserSettings.defaultSettings()
            let newId = try await userSettingsService.addUserSettings(settings!)
            settings?.id = newId
        }
        
        // update last logged in date
        settings?.lastLoggedIn = Date()
        try await userSettingsService.updateUserSettings(settings!)
        
        self.userSettings = settings!
        self.userSettings_original = settings!
    }
    
    
    func persistUserAndSettings() async throws {
        if user != user_original {
            try await UserService().updateUser(self.user)
            user_original = user
        }
        if userSettings != userSettings_original {
            try await UserSettingsService().updateUserSettings(self.userSettings)
            userSettings_original = userSettings
        }
    }
    
    @MainActor
    func handleSignIn() async -> Bool {
        guard let topVC = await UIApplication.shared.topViewController() else { return false }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            guard let idToken = result.user.idToken?.tokenString else {
                return false
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let _ = try await authProvider.signIn(with: credential)
            return true

        } catch {
            return false
        }
    }
    
    func logout() async throws {
        try authProvider.signOut()
    }
}

/**
 This extension allows Views to inject the manager as an EnvironmentObject and have it be pre-loaded to simulate the app flow.
 */
extension AuthenticationManager {
    static func forPreview(metric: Bool = true) -> AuthenticationManager {
        let manager = AuthenticationManager(
            authProvider: AuthProvider.Mock(),
            userService: UserService.Mock(),
            userSettingsService: UserSettingsService.Mock(metric: metric)
        )
        Task {
            do {
                try await manager.loadUserAndSettings()
            } catch {
                print(error)
            }
            
        }
        return manager
    }
}

extension UIApplication {
    
    func topViewController(base: UIViewController? = nil) async -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first(where: \.isKeyWindow)?.rootViewController

            if let nav = base as? UINavigationController {
                return await topViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
                return await topViewController(base: selected)
            }
            if let presented = base?.presentedViewController {
                return await topViewController(base: presented)
            }
            return base
        }
}
