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
    @EnvironmentObject var auth: AuthenticationManager
    
    @Binding var checkIn: CheckIn
    
    @StateObject var viewModel: ViewModel
    @State private var showAccommodationSelect = false
    @State private var showDateSelector = false
    @State private var showDistanceSelector = false
    @State private var showZeroDaysSelector = false
    @State private var showOffTrailDaysSelector = false
    
    @State private var dateDescription: String? = nil
    @State private var isSaving: Bool = false
    @State var localDistance: Measurement<UnitLength> = Measurement(value: 0, unit: .kilometers)
    
    @FocusState private var focusedView: FocusableViews?
    
    private var onSaved: ((Bool) -> Void)? = nil
    
    private var image: Image? {
        if viewModel.checkIn.image.hasImage {
            return Image(viewModel.checkIn.image.storageUrl)
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
                    
                    Button {
                        showDistanceSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text(localDistance.formatted(dp: 0))
                                .foregroundStyle(localDistance.value > 0 ? .primary : Color(.appPlaceholder) )
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .styleBorderLight()
                        .foregroundStyle(Color(.appText))
                    }
                    .padding(.bottom)
                    
                    // We aren't binding to anything here since the image we browse to needs to be persisted to Storage only if we save.
//                    StorageImageEditorView(storageImage: $viewModel.checkIn.image)
//                        .onImageDataChanged { data, contentType in
//                            // store this data on the viewModel so we know to replace/add a new image
//                            // when this checkin is saved we're going to redefine these properties
//                            viewModel.newImageData = data
//                            viewModel.newImageContentType = contentType
//                        }
//                        .onRemove {
//                            if (!checkIn.image.hasImage) {
//                                // let the viewModel know to delete the existing image on save
//                                viewModel.deleteImageOnSave = true
//                            }
//                            
//                            // clear new image data so we don't add any images
//                            viewModel.newImageData = nil
//                            viewModel.newImageContentType = nil
//                        }
//                        .padding(.bottom)
//                    
                    Divider()
                    
                    Text("Are you taking a few days off?")
                        .infoDetails("Time Out", "A rest day... an off trail day...")
                        .padding(.vertical)
                    
                    HStack {
                        Text("Rest Day(s)")
                        Spacer()
                        Button {
                            showZeroDaysSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "zzz")
                                Text("\(viewModel.checkIn.numberOfRestDays) \(viewModel.checkIn.numberOfRestDays == 1 ? "day" : "days")")
                                    .foregroundStyle(viewModel.checkIn.numberOfRestDays > 0 ? .primary : Color(.appPlaceholder) )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                        .frame(width: 160)
                    }
                    
                    HStack {
                        Text("Off Trail Day(s)")
                        Spacer()
                        Button {
                            showOffTrailDaysSelector = true
                        } label: {
                            HStack {
                                Image(systemName: "bus.fill")
                                Text("\(viewModel.checkIn.numberOfOffTrailDays) \(viewModel.checkIn.numberOfOffTrailDays == 1 ? "day" : "days")")
                                    .foregroundStyle(viewModel.checkIn.numberOfOffTrailDays > 0 ? .primary : Color(.appPlaceholder) )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                        .frame(width: 160)
                    }
                    .padding(.bottom)
                    
                    Divider()
                    
                    Toggle(isOn: $viewModel.checkIn.resupply) {
                        HStack {
                            Image(systemName: "cart")
                            Text("Did you resupply here?")
                        }
                    }
                    .padding(.vertical)
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
                                // copy changes back to the bound checkIn to refresh the parent view
                                self.checkIn = viewModel.checkIn
                                self.isSaving = false
                                
                                // let delegates know the save was successful
                                self.onSaved?(true)
                                dismiss()
                            } catch {
                                self.isSaving = false
                                self.onSaved?(false)
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
                        title: "Where did you sleep?", noSelection: true) { item in
                            SelectableItem(id: item.id ?? UUID().uuidString, name: item.name, order: item.order, imageName: item.imageName)
                        }
                    
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
                AppMeasurementPicker<UnitLength>(measurement: $localDistance, title: "Pick a distance")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(350)])
                    
            }
            .onChange(of: localDistance) { old, new in
                print(new.converted(to: .kilometers).description)
                viewModel.checkIn.distanceWalked = new.converted(to: .kilometers)
            }
            
            .sheet(isPresented: $showZeroDaysSelector) {
                AppNumberPicker(title: "Zero Days", number: $viewModel.checkIn.numberOfRestDays, unitDescription: "days")
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showOffTrailDaysSelector) {
                AppNumberPicker(title: "Off Trail Days", number: $viewModel.checkIn.numberOfOffTrailDays, unitDescription: "days")
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.medium])
            }
            .onAppear {
                // prepare the view
                Task {
                    do {
                        try await viewModel.loadAccommodationLookups()
                        
                        // create a distance value that is in the user's preferred distance unit. We'll bind this to our picker control and when updated set back on the checkIn.distance binding.
                        localDistance = checkIn.distanceWalked.converted(to: auth.userSettings.preferredDistanceUnit)
                    } catch {
                        ErrorLogger.shared.log(error)
                    }
                }
            }
            
        }
    }
    
    func onSaved(_ handler: ((Bool) -> Void)?) -> EditCheckInView {
        var copy = self
        copy.onSaved = handler
        return copy
    }
}

#Preview {
    @Previewable @State var checkIn = CheckIn.sample()
    VStack {
        EditCheckInView(checkIn: $checkIn,
                        viewModel: EditCheckInView.ViewModel(
                            checkIn: checkIn,
                            checkInService: CheckInService.Mock(),
                            lookupService: LookupService.Mock(),
                            storageService: StorageService.Mock()))
        .environmentObject(AuthenticationManager.forPreview(metric: false))
    }
}
