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
    @State private var newHike: Hike?
    @State private var navigateToHikeView: Bool = false
    
    init(trail: Trail) {
        self.init(trail: trail, viewModel: ViewModel(hikeService: HikerService(), checkInService: CheckInService()))
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
                
                Spacer()
                
                AppCapsuleButton("Create Journal") {
                    self.isSaving = true
                    if let checkInAnnotation = trail.startLocations.first(where: { $0.title == selectedStartLocation?.title }) {
                        Task {
                            do {
                                self.newHike = try await viewModel.addHike(trail: trail, startLocation: checkInAnnotation)
                                self.navigateToHikeView = true
                            } catch {
                                ErrorLogger.shared.log(error)
                            }
                            self.isSaving = false
                        }
                    }
                }.disabled(isSaving)
            }
            .padding(.horizontal, 20)
            .navigationDestination(isPresented: $navigateToHikeView) {
                if let hike = self.newHike {
                    HikeView(hike: hike)
                }
            }
        }
        
    }
}

#Preview {
    NewJournalStep2View(trail: Trail.sample, viewModel: NewJournalStep2View.ViewModel(hikeService: HikerServiceMock(), checkInService: CheckInServiceMock()))
}
