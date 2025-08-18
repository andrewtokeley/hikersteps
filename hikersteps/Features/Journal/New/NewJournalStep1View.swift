//
//  NewHikeView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 07/08/2025.
//

import SwiftUI

struct NewJournalStep1View: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCountryName: String = "-"
    @State private var selectedCountryIdentifier: String = "-"

    @State private var trails: [Trail] = []
    @State private var selectedTrailName: String = "-"
    @State private var selectedTrailId: String = "-"
    
    @State private var showCountrySelect: Bool = false
    
    @StateObject private var viewModel: ViewModel
    
    init() {
        self.init(viewModel: ViewModel(trailService: TrailService()))
        
        if let countryCode = Locale.current.region?.identifier {
            if let countryName = Locale.current.localizedString(forRegionCode: countryCode) {
                _selectedCountryName = State(initialValue: countryName)
                _selectedCountryIdentifier = State(initialValue: countryCode)
                
                return
            }
        }
    }
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    AppCircleButton(size: 30, imageSystemName: "xmark") {
                        dismiss()
                    }
                    .style(.filled)
                }
                .padding(.top)
                Group {
                    Text("Create a New Journal")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
                .foregroundStyle(.primary)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                
                Text("That's exciting!")
                Text("Which trail are you walking?")
                    .padding(.bottom)
                
                List {
                    ForEach(trails) { trail in
                        NavigationLink {
                            NewJournalStep2View(trail: trail)
                        } label: {
                            HStack {
                                Text(CountryManager.country(for: trail.countryCode)?.flag ?? "")
                                Text(trail.name)
                            }
                        }
                    }
                    
                }
                .listStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
        .task {
            do {
                self.trails = try await viewModel.loadTrails()
            } catch {
                ErrorLogger.shared.log(error)
            }
        }
    }
    
}

#Preview {
    NewJournalStep1View(viewModel: NewJournalStep1View.ViewModel(trailService: TrailService.Mock()))
}
