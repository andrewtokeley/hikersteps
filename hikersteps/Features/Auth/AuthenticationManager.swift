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

protocol AuthProviderProtocol {
    var isLoggedIn: Bool { get }
    var uid: String? { get }
    var displayName: String? { get }
    var email: String? { get }
    func signIn(with credentials: AuthCredential) async throws
    func signOut() throws
}

class AuthProvider: AuthProviderProtocol {
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    var uid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var displayName: String? {
        return Auth.auth().currentUser?.displayName
    }
    
    var email: String? {
        return Auth.auth().currentUser?.email
    }
    
    func signIn(with credentials: AuthCredential) async throws {
        return Auth.auth().signIn(with: credentials)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

class AuthProviderMock: AuthProviderProtocol {
    var isLoggedIn: Bool = true
    
    var uid: String? = "abs"
    
    var displayName: String? = "Andrew Tokeley (display)"
    
    var email: String? = "andrewtokeley@gmail.com"
    
    func signIn(with credentials: AuthCredential) async throws {
    }
    
    func signOut() throws {
        isLoggedIn = false
    }
}

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
    
    func handleSignIn() async
    
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
        
        userSettings = UserSettings.defaultSettings
        userSettings_original = userSettings
    }
    
    private func loadUser() async throws {
        guard authProvider.isLoggedIn else { return }
        
        var user: User?
        user = try await UserService().getUser()
        
        // if no document exists, this is the first time the user has signed in - create a User document
        if user == nil {
            if let uid = authProvider.uid, let displayName = authProvider.displayName {
                user = User(uid: uid, username: "", displayName: displayName, isActive: true)
                let _ = try await UserService().addUser(user!)
            } else {
                throw ServiceError.generalError("Can't add User - authProvider invalid")
            }
        }
        self.user = user!
        self.user_original = user!
    }
    
    private func loadUserSettings() async throws {
        var settings: UserSettings?
        settings = try await UserSettingsService().getUserSettings()
        if settings == nil {
            // this is the first time the user has signed in - create some default settings for them
            settings = UserSettings.defaultSettings
            let newId = try await userSettingsService.addUserSettings(settings!)
            settings?.id = newId
        }
        self.userSettings = settings!
        self.userSettings_original = settings!
    }
    
    func loadUserAndSettings() async throws {
        try await loadUser()
        try await loadUserSettings()
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
    
    func handleSignIn() async {
        guard let topVC = await UIApplication.shared.topViewController() else { return }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            guard let idToken = result.user.idToken?.tokenString else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let _ = try await authProvider.signIn(with: credential)

        } catch {
            print("Google Sign-In error: \(error.localizedDescription)")
        }
    }
    
    func logout() async throws {
        try Auth.auth().signOut()
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
