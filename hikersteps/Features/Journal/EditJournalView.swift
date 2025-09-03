//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

struct EditJournalView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var journal: Journal
    
    @FocusState private var focusedView: FocusableViews?

    @StateObject var viewModel: ViewModel
    @State private var showDateSelector = false
    @State private var isSaving: Bool = false
    @State private var topSectionHeight: CGFloat = 260
    private var onSaved: (() -> Void)? = nil
    
    enum FocusableViews: Hashable {
        case name
        case accommodation
        case image
        case notes
        case resupplyNotes
    }
    
    init(journal: Binding<Journal>) {
        // we pass in the wrapped value to the viewmodel so that we can choose whether to copy the changes back to the parent depending on whether changes are saved or canceled.
        self.init(journal: journal,
                  viewModel: ViewModel(journal: journal.wrappedValue,
                                       journalService: JournalService(),
                                       trailService: TrailService()))
    }
    
    init(journal: Binding<Journal>, viewModel: ViewModel) {
        _journal = journal
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack {
                        TextField("Journal Name", text: $viewModel.journal.name)
                            .padding()
                            .styleBorderLight(focused: focusedView == .name)
                            .focused($focusedView, equals: .name)
                            .padding(.bottom)
                        
                        Button {
                            showDateSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(viewModel.journal.startDate.asDateString())
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                        .padding(.bottom)
                        
                        AppTextEditor(text: $viewModel.journal.description, placeholder: "Summary of your journal")
                            .frame(height: 300)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top)
                
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        print("cancel")
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .disabled(self.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving" : "Save") {
                        self.isSaving = true
                        
                        // Save to firestore
                        Task {
                            do {
                                // work out what sort of image action to perform
                                let _ = try await viewModel.updateCheckIn()
                                
                                //copy changes back to the bound checkIn to refresh the parent view
                                self.journal = viewModel.journal
                                self.isSaving = false
                                dismiss()
                            } catch {
                                self.isSaving = false
                                ErrorLogger.shared.log(error)
                            }
                        }
                    }
                    .disabled(self.isSaving)
                }
            }
            .sheet(isPresented: $showDateSelector) {
                AppDateSelect(selectedDate: $viewModel.journal.startDate, title: "Start Date")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
            .presentationDetents([.medium])
        }
        
    }
        
    func onSaved(_ handler: (() -> Void)?) -> EditJournalView {
        var copy = self
        copy.onSaved = handler
        return copy
    }
    
    func topSafeAreaInset() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.safeAreaInsets.top ?? 0
    }
}

#Preview {
    @Previewable @State var hike = Journal.sample
    EditJournalView(journal: $hike,
                 viewModel: EditJournalView.ViewModel(
                        journal: hike,
                        journalService: JournalService.Mock(),
                        trailService: TrailService.Mock()))
}
