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
    var photoUrl: URL? { get }
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
    
    var photoUrl: URL? {
        if let url = Auth.auth().currentUser?.photoURL {
            return url
        } else if let name = displayName,
            let avatarUrl = URL(string: "https://ui-avatars.com/api/?name=\(name)&background=random") {
            return avatarUrl
        } else {
            return nil
        }
        
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

extension AuthProvider {
    class Mock: AuthProviderProtocol {
        
        var isLoggedIn: Bool = true
        
        var uid: String? = "1OZ0zM1OHac848DLo9oyifKFEg13"
        
        var displayName: String? = "Andrew Tokeley (display)"
        
        var email: String? = "andrewtokeley@gmail.com"
        
        func signIn(with credentials: AuthCredential) async throws {
        }
        
        var photoUrl: URL? {
            return URL(string: "https://ui-avatars.com/api/?name=Andrew+Tokeley&background=random&rounded=true")
        }
        
        func signOut() throws {
            isLoggedIn = false
        }
    }
}
