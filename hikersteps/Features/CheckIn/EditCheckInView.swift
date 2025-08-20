//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

/**
 EditCheckInView is responsible for updating a single day of a Journal
 */
struct EditCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var checkIn: CheckIn
    
    @StateObject var viewModel: ViewModel
    
    @State private var showAccommodationSelect = false
    @State private var showDateSelector = false
    @State private var showDistanceSelector = false
    @State private var showZeroDaysSelector = false
    @State private var dateDescription: String? = nil
    
    @State private var isSaving: Bool = false
    
    @FocusState private var focusedView: FocusableViews?
    
    private var onSaved: (() -> Void)? = nil
    
    private var image: Image? {
        if let url = viewModel.checkIn.images.first?.storageUrl {
            return Image(url)
        }
        return nil
    }
    
    enum FocusableViews: Hashable {
        case title
        case accommodation
        case image
        case notes
        case resupplyNotes
    }
    
    /**
     Initialise the View with a binding to a checkin that should be edited. This may be a new checkin (no id) or an existing CheckIn.
     
     Note, the viewmodel maintains a copy of the bound wrapped value which the view binds to. If the edit is saved the edited copy is copied back to the bound value provided by the parent.
     */
    init(checkIn: Binding<CheckIn>) {
        self.init(checkIn: checkIn,
                  viewModel: ViewModel(checkIn: checkIn.wrappedValue,
                                       checkInService: CheckInService(),
                                       lookupService: LookupService(),
                                      storageService: StorageService()))
        self.focusedView = .title
    }
    
    init(checkIn: Binding<CheckIn>, viewModel: ViewModel) {
        _checkIn = checkIn
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    TextField("Where Are You Staying", text: $viewModel.checkIn.title)
                        .padding()
                        .styleBorderLight(focused: focusedView == .title)
                        .focused($focusedView, equals: .title)
                        .padding(.vertical)
                    
                    AppTextEditor(text: $viewModel.checkIn.notes, placeholder: "How did it go?")
                        .frame(height: 300)
                        .padding(.bottom)
                    
                    Button {
                        showAccommodationSelect = true
                    } label: {
                        HStack {
                            Image(systemName: viewModel.checkIn.accommodation.imageName)
                            if (viewModel.checkIn.accommodation == LookupItem.noSelection()) {
                                Text("Sleeping arrangements?")
                                    .foregroundColor(Color(.appPlaceholder))
                            } else {
                                Text(viewModel.checkIn.accommodation.name)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .styleBorderLight()
                        .foregroundStyle(Color(.appText))
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Button {
                            showDistanceSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "figure.walk")
                                Text(viewModel.checkIn.distance.description)
                                    .foregroundStyle(viewModel.checkIn.distance.number > 0 ? .primary : Color(.appPlaceholder) )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                        Button {
                            showZeroDaysSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "zzz")
                                Text("\(viewModel.checkIn.numberOfRestDays) days")
                                    .foregroundStyle(viewModel.checkIn.numberOfRestDays > 0 ? .primary : Color(.appPlaceholder) )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                    }
                    .padding(.bottom)
                    
                    // We aren't binding to anything here since the image we browse to needs to be persisted to Storage only if we save.
                    StorageImageEditorView(imageURL: viewModel.checkIn.images.first?.storageUrl)
                        .onImageDataChanged { data, contentType in
                            // store this data on the viewModel so we know to replace/add a new image
                            print("new image data returned")
                            // when this checkin is saved we're going to redefine these properties
                            viewModel.newImageData = data
                            viewModel.newImageContentType = contentType
                        }
                        .onRemove {
                            print("removed image from StorageImageEditor")
                            if (!checkIn.images.isEmpty) {
                                // let the know to delete the existing image on save
                                viewModel.deleteImageOnSave = true
                            }
                            
                            // clear new image data so we don't add any images
                            viewModel.newImageData = nil
                            viewModel.newImageContentType = nil
                        }
                     
                    Text("Resupply")
                        .font(.title)
                    
                    Toggle(isOn: $viewModel.checkIn.resupply) {
                        HStack {
                            Image(systemName: "cart")
                            Text("Did you resupply here?")
                        }
                    }
                    .tint(.accentColor)
                    .onChange(of: viewModel.checkIn.resupply) { oldValue, newValue in
                        if newValue {
                            focusedView = .resupplyNotes
                        } else {
                            focusedView = nil
                        }
                    }
                    
                    
                    if viewModel.checkIn.resupply {
                        AppTextEditor(text: $viewModel.checkIn.resupplyNotes, placeholder: "How was it?")
                            .frame(height: 200)
                            .focused($focusedView, equals: .resupplyNotes)
                            .padding(.bottom)
                    }
                    
                    Divider()
                        .padding()
                    
                }
            }
            .padding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(viewModel.checkIn.date.asDateString(withYear: false))
                        Button {
                            showDateSelector = true
                        } label: {
                            Image(systemName: "ellipsis.circle").rotationEffect(Angle(degrees: 90))
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
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
                                try await viewModel.save()
                                //copy changes back to the bound checkIn to refresh the parent view
                                self.checkIn = viewModel.checkIn
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
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAccommodationSelect) {
                NavigationStack {
                    AppListSelector(
                        items: viewModel.accommodationLookups,
                        selectedItem: $viewModel.checkIn.accommodation,
                        title: "Where did you sleep?", noSelection: true)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: $showDateSelector) {
                AppDateSelect(selectedDate: $viewModel.checkIn.date, title: "Day")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
            .presentationDetents([.medium])
            
            .sheet(isPresented: $showDistanceSelector) {
                // Need to handle units
                AppNumberPicker(title: "Distance Walked", number: $viewModel.checkIn.distance.number, units: [.km, .mi], unit: $viewModel.checkIn.distance.unit)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(350)])
            }
            
            .sheet(isPresented: $showZeroDaysSelector) {
                AppNumberPicker(title: "Zero Days", number: $viewModel.checkIn.numberOfRestDays, subTitle: "Are you taking a rest day (or more!) tomorrow?", units: [.days])
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(350)])
            }
            
            
            .onAppear {
                // get accommodation looks
                Task {
                    do {
                        try await viewModel.loadAccommodationLookups()
                    } catch {
                        ErrorLogger.shared.log(error)
                    }
                }
            }
            
        }
    }
    
    func onSaved(_ handler: (() -> Void)?) -> EditCheckInView {
        var copy = self
        copy.onSaved = handler
        return copy
    }
}

#Preview {
    @Previewable @State var checkIn = CheckIn.sample()
    EditCheckInView(checkIn: $checkIn,
                    viewModel: EditCheckInView.ViewModel(
                        checkIn: checkIn,
                        checkInService: CheckInService.Mock(),
                        lookupService: LookupService.Mock(),
                        storageService: StorageService.Mock()))
}
