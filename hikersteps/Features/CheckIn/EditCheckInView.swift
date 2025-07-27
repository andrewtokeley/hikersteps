//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

struct EditCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    
    /**
        A copy of the checkIn being edited
     */
    let checkIn: CheckIn

    var onDeleteRequest: (()-> Void)? = nil
    
    /// Properties that can be updated
    /// TODO: can i just use the checkIn object itself?
    @State private var isCreating: Bool = false
    @State private var accommodationList: [LookupItem]
    @State private var showAccommodationSelect = false
    @State private var showDateSelector = false
    @State private var showDistanceSelector = false
    @State private var showZeroDaysSelector = false
    @State private var title: String
    @State private var notes: String
    @State private var date: Date
    @State private var dateDescription: String?
    @State private var distanceWalked: Int
    @State private var distanceUnit: Unit
    @State private var numberOfRestDays: Int
    @State private var numberOfOffTrailDays: Int
    @State private var accommodation: LookupItem?
    @State private var notesCharacterCount: Int = 0
    @State private var resupplied: Bool = false
    @State private var resupplyNotes: String
    @State private var imageURL: String?
    
    private var image: Image? {
        if let imageURL = imageURL {
            return Image(imageURL)
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
    @FocusState private var focusedView: FocusableViews?
    
    init(checkIn: CheckIn?, onDeleteRequest: (() -> Void)? = nil) {
        
        self.onDeleteRequest = onDeleteRequest
        
        let checkInToEdit: CheckIn
        if let checkIn {
            checkInToEdit = checkIn
            isCreating = false
        } else {
            checkInToEdit = CheckIn.newWithDefaults
            isCreating = true
        }
        self.checkIn = checkInToEdit
        self.title = checkInToEdit.title ?? ""
        self.notes = checkInToEdit.notes ?? ""
        self.date = checkInToEdit.date
        self.distanceWalked = checkInToEdit.distanceWalked
        self.distanceUnit = .km
        self.numberOfRestDays = checkInToEdit.numberOfRestDays
        self.numberOfOffTrailDays = checkInToEdit.numberOfOffTrailDays
        self.accommodation = LookupItem(id: "2", name: "Hotel", imageRotation: nil, imageName: "hotel") //checkInToEdit.accommodation
        self.resupplied = checkInToEdit.resupply ?? false
        self.resupplyNotes = checkInToEdit.resupplyNotes ?? ""
        self.imageURL = checkInToEdit.images.first?.storageUrl
        self.accommodationList = []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack (alignment: .leading) {
                    
                    TextField("Name of where you stayed", text: $title)
                        .padding()
                        .styleBorderLight(focused: focusedView == .title)
                        .focused($focusedView, equals: .title)
                        .padding(.bottom)
                    
                    Button {
                        showAccommodationSelect = true
                    } label: {
                        HStack {
                            Image(systemName: accommodation?.sfSymbolName ?? "tent")
                            Text(accommodation?.name ?? "Tent")
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
                            Text(date.asDateString())
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
                                Text("\(distanceWalked) \(distanceUnit.rawValue)")
                                    .foregroundStyle(distanceWalked > 0 ? .primary : .secondary )
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
                                Text("\(numberOfRestDays) days")
                                    .foregroundStyle(numberOfRestDays > 0 ? .primary : .secondary )
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .styleBorderLight()
                            .foregroundStyle(Color(.appText))
                        }
                    }
                    .padding(.bottom)
                    .onChange(of: numberOfRestDays) { oldValue, newValue in
                        // update the date range this checkin covers
                        if newValue > 0 {
                            dateDescription = "date span changed"
                        }
                        else {
                            dateDescription = nil
                        }
                    }
                    
                    AppImagePicker(image: image)
                        .padding(.bottom)
                    
                    AppTextEditor(text: $notes, placeholder: "Write something about your day :)")
                        .frame(height: 300)
                        .padding(.bottom)
                    
                    Text("Resupply")
                        .font(.title)
                    
                    Toggle(isOn: $resupplied) {
                        HStack {
                            Image(systemName: "cart")
                                .foregroundColor(.orange)
                            Text("Did you resupply here?")
                        }
                    }
                    .tint(.accentColor)
                    .onChange(of: resupplied) { oldValue, newValue in
                        if newValue {
                            focusedView = .resupplyNotes
                        } else {
                            focusedView = nil
                        }
                    }
                    
                    
                    if resupplied {
                        AppTextEditor(text: $resupplyNotes, placeholder: "How was it?")
                            .frame(height: 200)
                            .focused($focusedView, equals: .resupplyNotes)
                            .padding(.bottom)
                    }
                    
                    Divider()
                        .padding()
                    
                    HStack {
                        Spacer()
                        Button("Delete") {
                            onDeleteRequest?()
                            dismiss()
                        }
                        .capsuleStyled(background: .red, foreground: .white)
                        .padding()
                        Spacer()
                    }
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
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAccommodationSelect) {
                NavigationStack {
                    AppListSelector(selectedItem: $accommodation, items: accommodationList, title: "Where did you sleep?")
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium])
                }
            }
            .sheet(isPresented: $showDateSelector) {
                AppDateSelect(selectedDate: $date, title: "Check-In Date")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
            .presentationDetents([.medium])
            
            .sheet(isPresented: $showDistanceSelector) {
                AppNumberPicker(title: "Distance Walked", number: $distanceWalked, units: [.km, .mi], unit: $distanceUnit)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(350)])
            }
            
            .sheet(isPresented: $showZeroDaysSelector) {
                AppNumberPicker(title: "Zero Days", number: $numberOfRestDays, subTitle: dateDescription, units: [.days])
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(350)])
            }
            
            
            .onAppear {
                // get accommodation looks
                LookupService.getAccommodationLookups { items, error in
                    if let items = items {
                        self.accommodationList = items
                    }
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
}

#Preview {
    EditCheckInView(checkIn: CheckIn.newWithDefaults, onDeleteRequest: {
        print("hi")
    })
}
