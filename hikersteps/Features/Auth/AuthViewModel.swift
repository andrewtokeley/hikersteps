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

struct AuthenticatedUser {
    var uid: String?
    var displayName: String?
    var email: String?
}

protocol AuthViewModelProtocol: ObservableObject {
    var isLoggedIn: Bool { get }
    var loggedInUser: AuthenticatedUser?  { get }
    func handleSignIn() async
}

class AuthViewModel: AuthViewModelProtocol {
    @Published var isLoggedIn: Bool = false
    @Published var loggedInUser: AuthenticatedUser?
    
    init() {
        isLoggedIn = Auth.auth().currentUser != nil
        loggedInUser = AuthenticatedUser(
            uid: Auth.auth().currentUser?.uid,
            displayName: Auth.auth().currentUser?.displayName ?? "Unknown",
            email: Auth.auth().currentUser?.email ?? nil
        )
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
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            await MainActor.run {
                self.isLoggedIn = true
                self.loggedInUser = AuthenticatedUser(
                    uid: Auth.auth().currentUser?.uid,
                    displayName: Auth.auth().currentUser?.displayName ?? "Unknown",
                    email: Auth.auth().currentUser?.email ?? nil
                )
            }
        } catch {
            print("Google Sign-In error: \(error.localizedDescription)")
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}

class AuthViewModelMock: AuthViewModel {
    
    override init() {
        super.init()
        self.isLoggedIn = true
        self.loggedInUser = AuthenticatedUser(uid: "123", displayName: "Tokes (Mock)", email: "andrewtokeley+mock@gmail.com")
    }
    
    override func handleSignIn() async {
        //
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
