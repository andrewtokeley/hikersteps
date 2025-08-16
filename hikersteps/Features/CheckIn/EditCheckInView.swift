//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

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
    
    init(checkIn: Binding<CheckIn>) {
        // we pass in the wrapped value to the viewmodel so that we can choose whether to copy the changes back to the parent depending on whether changes are saved or canceled.
        self.init(checkIn: checkIn,
                  viewModel: ViewModel(checkIn: checkIn.wrappedValue,
                                       checkInService: CheckInService(),
                                       lookupService: LookupService(),
                                      storageService: StorageService()))
    }
    
    init(checkIn: Binding<CheckIn>, viewModel: ViewModel) {
        _checkIn = checkIn
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    TextField("Name of where you stayed", text: $viewModel.checkIn.title)
                        .padding()
                        .styleBorderLight(focused: focusedView == .title)
                        .focused($focusedView, equals: .title)
                        .padding(.bottom)

                    Button {
                        showAccommodationSelect = true
                    } label: {
                        HStack {
                            Image(systemName: viewModel.checkIn.accommodation.imageName)
                            Text(viewModel.checkIn.accommodation.name)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .styleBorderLight()
                        .foregroundStyle(Color(.appText))
                    }
                    .padding(.bottom)
                    
                    Button {
                        showDateSelector = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text(viewModel.checkIn.date.asDateString())
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
                                    .foregroundStyle(viewModel.checkIn.distance.number > 0 ? .primary : .secondary )
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
                                    .foregroundStyle(viewModel.checkIn.numberOfRestDays > 0 ? .primary : .secondary )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                    }
                    .padding(.bottom)
                    .onChange(of: viewModel.checkIn.numberOfRestDays) { oldValue, newValue in
                        // update the date range this checkin covers
                        if newValue > 0 {
                            dateDescription = "date span changed"
                        }
                        else {
                            dateDescription = nil
                        }
                    }
                    
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
                     
                    AppTextEditor(text: $viewModel.checkIn.notes, placeholder: "Write something about your day :)")
                        .frame(height: 300)
                        .padding(.bottom)
                    
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
                                // work out what sort of image action to perform
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
                AppNumberPicker(title: "Zero Days", number: $viewModel.checkIn.numberOfRestDays, subTitle: dateDescription, units: [.days])
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
                        checkInService: CheckInServiceMock(),
                        lookupService: LookupServiceMock(),
                        storageService: StorageSerivceMock()))
}
