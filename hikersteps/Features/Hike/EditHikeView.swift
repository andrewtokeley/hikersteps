//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

struct EditHikeView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var hike: Hike
    
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
    
    init(hike: Binding<Hike>) {
        // we pass in the wrapped value to the viewmodel so that we can choose whether to copy the changes back to the parent depending on whether changes are saved or canceled.
        self.init(hike: hike,
                  viewModel: ViewModel(hike: hike.wrappedValue,
                                       hikeService: HikerService(),
                                       trailService: TrailService()))
    }
    
    init(hike: Binding<Hike>, viewModel: ViewModel) {
        _hike = hike
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
//                ZStack (alignment: .bottom) {
//                    Image("hiker-journal")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: topSectionHeight + topSafeAreaInset())
//                    
//                    Text("New Journal")
//                        .foregroundStyle(.white)
//                        .font(.title)
//                        .bold()
//                        .padding(.bottom, 20)
//                        .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
//                }
//                .clipped()
//                .ignoresSafeArea(edges: .top)
//                .frame(height: topSectionHeight)
//                .background(.red)
//                
                ScrollView {
                    VStack {
                        TextField("Journal Name", text: $viewModel.hike.name)
                            .padding()
                            .styleBorderLight(focused: focusedView == .name)
                            .focused($focusedView, equals: .name)
                            .padding(.bottom)
                        
                        Button {
                            showDateSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(viewModel.hike.startDate.asDateString())
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                        .padding(.bottom)
                        
                        AppTextEditor(text: $viewModel.hike.description, placeholder: "Summary of your journal")
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
                                let _ = try await viewModel.save()
                                
                                //copy changes back to the bound checkIn to refresh the parent view
                                self.hike = viewModel.hike
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
                AppDateSelect(selectedDate: $viewModel.hike.startDate, title: "Start Date")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
            .presentationDetents([.medium])
        }
        
    }
        
    func onSaved(_ handler: (() -> Void)?) -> EditHikeView {
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
    @Previewable @State var hike = Hike.sample
    EditHikeView(hike: $hike,
                 viewModel: EditHikeView.ViewModel(
                        hike: hike,
                        hikeService: HikerServiceMock(),
                        trailService: TrailService.Mock()))
}
