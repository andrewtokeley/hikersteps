//
//  Home.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct HomeView: View {
    // app state injected from hikerstepsApp
    @EnvironmentObject var auth: AuthViewModel
    
    // ensures we get notified when the viewmodel updates any of its published properties
    @StateObject private var viewModel = ViewModel()
    
    // view's own state
    @State private var hasLoaded = false
    
    init() {
    }
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack() {
            VStack {
                if auth.isLoggedIn {
                    List {
                        ForEach(viewModel.hikes) { hike in
                            NavigationLink {
                                HikeView(hike: hike)
                            } label: {
                                VStack {
                                    Text(hike.name)
                                    Spacer()
                                    Text(hike.trail?.name ?? "")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    
                    VStack {
                        Text("\(auth.loggedInUser?.displayName ?? "Unknown User")")
                        Button("Log Out") {
                            auth.logout()
                        }
                    }
                } else {
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Login...")
                    }
                }
            }
            .navigationTitle("My Big Hikes")
        }
        .onAppear {
            if (!hasLoaded) {
                viewModel.loadHikes()
                hasLoaded = true
            }
        }
    }
}

#Preview {
    let mock = AuthViewModelMock() as AuthViewModel
    return HomeView(viewModel: HomeView.ViewModelMock())
        .environmentObject(mock)
}
