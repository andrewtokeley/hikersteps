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
    @Environment(\.dismiss) private var dismiss
    
    // The ViewModel for this view.
    @StateObject private var viewModel: ViewModel
    @State private var showNewHike: Bool = false
    
    @State private var selectedTrailForNewJournal: Trail?
    
    // The State managed by this view
    @State private var hasLoaded = false
    
    init() {
        self.init(viewModel: ViewModel(journalService: JournalService()))
    }
    
    /**
     Constructure to inject a custom view model, most likely for testing purposes
     */
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack() {
            VStack (alignment: .leading) {
                if auth.isLoggedIn {
                    Group {
                        if (hasLoaded) {
                            Text("Journals")
                        } else {
                            Text("Journals - Loading...")
                        }
                    }
                    .foregroundStyle(.primary)
                    .font(.title)
                    
                    ScrollView {
                        ForEach(viewModel.journals) { journal in
                            NavigationLink {
                                JournalView(hike: journal)
                            } label: {
                                HikeCard(hike: journal)
                                    .onDeleteRequest { journal in
                                        Task {
                                            do {
                                                hasLoaded = false
                                                try await viewModel.deleteJournal(journal: journal)
                                                try await viewModel.loadJournals()
                                                hasLoaded = true
                                            } catch {
                                                ErrorLogger.shared.log(error)
                                            }
                                        }
                                    }
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
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedTrailForNewJournal) { trail in
                NewJournalStep2View(trail: trail)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                selectedTrailForNewJournal = nil
                            }
                        }
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showNewHike = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NotificationView()) {
                        Image(systemName: "bell")
                            .imageScale(.large)
                    }
                }
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
                    try await viewModel.loadJournals()
                    hasLoaded = true
                } catch {
                    ErrorLogger.shared.log(error)
                }
            } else {
                print("didn't reload")
            }
        }
        .sheet(isPresented: $showNewHike) {
            NewJournalStep1View()
                .onTrailSelected { trail in
                    print("hi")
                    self.selectedTrailForNewJournal = trail
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            
        }
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    return HomeView(viewModel: HomeView.ViewModel(journalService: JournalService.Mock()))
        .environmentObject(mock)
}
