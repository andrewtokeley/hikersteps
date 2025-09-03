//
//  JournalListView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 29/08/2025.
//

import SwiftUI

struct JournalListView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    init() {
        self.init(viewModel: ViewModel(journalService: JournalService()))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Public") {
                    ForEach(viewModel.journals.filter({ j in
                        j.visibility == .everyone
                    })) { journal in
                        NavigationLink(destination: JournalView(journal: journal)) {
                            Text(journal.name)
                        }
                    }
                }
                Section("Private") {
                    ForEach(viewModel.journals.filter({ j in
                        j.visibility == .justMe
                    })) { journal in
                        NavigationLink(destination: JournalView(journal: journal)) {
                            Text(journal.name)
                        }
                    }
                }
            }
            .listStyle(.grouped)
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.loadJournals()
                } catch {
                    ErrorLogger.shared.log(error)
                }
            }
        }
        .navigationTitle("Journals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JournalListView(viewModel: JournalListView.ViewModel(journalService: JournalService.Mock())
    )
    .environmentObject(AuthenticationManager.forPreview())
}
