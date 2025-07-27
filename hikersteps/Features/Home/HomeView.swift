//
//  Home.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct HomeView: View {
    // Access to the authentication state, user info etc.
    @EnvironmentObject var auth: AuthenticationManager
    @EnvironmentObject var appState: AppState
    
    // The ViewModel for this view.
    @StateObject private var viewModel = ViewModel()
    
    // The State managed by this view
    @State private var hasLoaded = false
    
    init() {
        
    }
    
    /**
     Constructure to inject a custom view model, most likely for testing purposes
     */
    init(mockViewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: mockViewModel)
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
                            .environmentObject(appState)
                    } label: {
                        Text("Login...")
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                }
            }
        }
        .onAppear {
            // The view can appear multiple times, we only want to reload the hikes if they haven't been loaded before.
            if (!hasLoaded) {
                viewModel.loadHikes()
                hasLoaded = true
            }
        }
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    return HomeView(mockViewModel: HomeView.ViewModelMock())
        .environmentObject(mock)
}
