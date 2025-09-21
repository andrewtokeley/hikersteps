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
    
    @Environment(\.dismiss) private var dismiss
    
    // The ViewModel for this view.
    @StateObject private var viewModel: ViewModel
    @State private var showNewHike: Bool = false
    @State private var selectedJournalIndex: String?
    
    @State private var selectedTrailForNewJournal: Trail?
    
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
                if viewModel.journals.count > 0 {
                    TabView(selection: $selectedJournalIndex) {
                        ForEach(Array(viewModel.journals.enumerated()), id: \.element.id) { index, journal in
                            
                            NavigationLink(destination: JournalView(journal: journal)
                            ) {
                                JournalCardView(journal: journal)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    JournalCardView(journal: nil)
                        .onCreateRequest {
                            showNewHike = true
                        }
                }
            }
            .padding()
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
            do {
                try await viewModel.loadJournals()
                if let lastJournalIndex = auth.userSettings.lastJournalId {
                    selectedJournalIndex = lastJournalIndex
                }
            } catch {
                ErrorLogger.shared.log(error)
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
    HomeView(viewModel: HomeView.ViewModel(journalService: JournalService.Mock(newUser: true)))
        .environmentObject(AuthenticationManager.forPreview())
}
