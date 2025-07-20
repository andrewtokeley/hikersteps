//
//  RootView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        if auth.isLoggedIn {
            HomeView()
        } else {
            SplashView()
        }
    }
}

#Preview {
    let mock = AuthViewModelMock() as AuthViewModel
    mock.isLoggedIn = false
    return RootView()
        .environmentObject(mock)
}
