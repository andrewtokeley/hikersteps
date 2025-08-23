//
//  AuthProvider.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/08/2025.
//

import Foundation
import FirebaseAuth

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

extension AuthProvider {
    class Mock: AuthProviderProtocol {
        
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
}
