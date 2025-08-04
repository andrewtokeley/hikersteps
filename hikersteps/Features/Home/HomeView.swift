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
    @StateObject private var viewModel: ViewModel
    
    // The State managed by this view
    @State private var hasLoaded = false
    
    init() {
        self.init(viewModel: ViewModel(hikeService: HikerService()))
    }
    
    /**
     Constructure to inject a custom view model, most likely for testing purposes
     */
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack() {
            VStack {
                if auth.isLoggedIn {
                    ScrollView {
                        ForEach(viewModel.hikes) { hike in
                            NavigationLink {
                                HikeView(hike: hike)
                            } label: {
                             
                                HikeCard(hike: hike)
                                    .foregroundColor(Color(UIColor.label))
                            }
                        }
                    }.scrollIndicators(.hidden)
                    Spacer()
                    
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
            .padding()
            .navigationTitle("My Hikes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                    }
                }
            }
        }
        .task {
            if (!hasLoaded) {
                do {
                    try await viewModel.loadHikes()
                    hasLoaded = true
                } catch {
                    ErrorLogger.shared.log(error)
                }
            } else {
                print("didn't reload")
            }
        }
        
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    return HomeView(viewModel: HomeView.ViewModel(hikeService: HikerServiceMock()))
        .environmentObject(mock)
}
