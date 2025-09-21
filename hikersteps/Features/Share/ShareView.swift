//
//  ShareView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 17/09/2025.
//

import SwiftUI

struct ShareView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var shareOptions: [RadioOption]
    @State private var selectedShareOption: RadioOption?
    @StateObject var viewModel: ViewModel
    
    //@Binding var journal: Journal
    @Binding var visibility: JournalVisibility
    
    init(visibility: Binding<JournalVisibility>) {
        self.init(visibility: visibility, viewModel: ViewModel(journalService: JournalService()))
    }
    
    init(visibility: Binding<JournalVisibility>, viewModel: ViewModel) {
        _visibility = visibility
        
        _viewModel = StateObject(wrappedValue: viewModel)
        
        let options = [
            RadioOption(id: JournalVisibility.everyone.rawValue, title: "Public", subTitle: "Anyone can see your journal on the web, if you share them the link", icon: "person.3")
            , RadioOption(id: JournalVisibility.friendsOnly.rawValue, title: "Friends", subTitle: "Only your followers can see your journal", icon: "person.2")
            , RadioOption(id: JournalVisibility.justMe.rawValue, title: "Private", subTitle: "For your eyes only!", icon: "lock")
        ]
        
        _shareOptions = State(initialValue: options)
        _selectedShareOption = State(initialValue: options.first(where: {$0.id == visibility.wrappedValue.rawValue }) ?? options.last!  )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                //Text("Who can view this journal?")
                RadioButtonGroup(options: shareOptions, selected: $selectedShareOption)
                    .onChange(of: selectedShareOption) {
                        if let id = selectedShareOption?.id, let visibility = JournalVisibility(rawValue: id) {
                            self.visibility = visibility
                            dismiss()
                        }
                    }
                Spacer()
                
//                AppCapsuleButton("Update") {
//                    Task {
//                        do {
//                            if let selectedShareOption = selectedShareOption, let visibility = JournalVisibility(rawValue: selectedShareOption.id) {
//                                try await viewModel.updateShareStatus(journal: journal, visibility: visibility)
//                                dismiss()
//                            }
//                        } catch {
//                            ErrorLogger.shared.log(error)
//                        }
//                    }
//                }
            }
            .padding()
            .navigationTitle("Visibility")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    @Previewable @State var visibility = JournalVisibility.everyone
    ShareView(visibility: $visibility)
}
