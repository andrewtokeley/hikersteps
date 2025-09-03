//
//  SelectStartView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 14/08/2025.
//

import SwiftUI

struct NewJournalStep2View: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ViewModel
    
    var trail: Trail
    
    var locationOptions: [RadioOption] {
        var options = trail.startLocations.map {
            RadioOption(title: $0.title ?? "unknown", icon: "map-pin")
        }
        options.append(RadioOption(title: "Not sure where yet", icon: ""))
        return options
    }
    
    @State private var selectedStartLocation: RadioOption?
    @State private var isSaving: Bool = false
    @State private var newJournal: Journal?
    @State private var navigateToJournalView: Bool = false
    
    init(trail: Trail) {
        self.init(trail: trail, viewModel: ViewModel(journalService: JournalService(), checkInService: CheckInService()))
    }
    
    init(trail: Trail, viewModel: ViewModel) {
        self.trail = trail
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Where are you starting?")
                    .font(.title)
                Text("You can change this later")
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
                RadioButtonGroup(options: locationOptions, selected: $selectedStartLocation)
                    .disabled(self.isSaving)
                
                Spacer()
                
                AppCapsuleButton("Create Journal") {
                    self.isSaving = true
                    if let checkInAnnotation = trail.startLocations.first(where: { $0.title == selectedStartLocation?.title }) {
                        Task {
                            do {
                                self.newJournal = try await viewModel.addJournal(trail: trail, startLocation: checkInAnnotation)
                                self.navigateToJournalView = true
                            } catch {
                                ErrorLogger.shared.log(error)
                            }
                        }
                    }
                    self.isSaving = false
                }
                .disabled(isSaving)
            }
            .padding(.horizontal, 20)
            .navigationDestination(isPresented: $navigateToJournalView) {
                if let journal = self.newJournal {
                    JournalView(journal: journal)
                }
            }
        }
        
    }
}

#Preview {
    NewJournalStep2View(trail: Trail.sample, viewModel: NewJournalStep2View.ViewModel(journalService: JournalService.Mock(), checkInService: CheckInService.Mock()))
}
