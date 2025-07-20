//
//  EditCheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct EditCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var lastScrollOffset: CGFloat = 0
    
    /**
        A copy of the checkIn being edited
     */
    let checkIn: CheckIn
    
    @State private var isCreating: Bool = false
    @State private var accommodationList: [LookupItem]
    @State private var showAccommodationSelect = false
    @State private var showDateSelector = false
    
    /// Properties that can be updated
    @State private var title: String
    @State private var notes: String
    @State private var date: Date
    @State private var distanceWalked: Int
    @State private var numberOfRestDays: Int
    @State private var numberOfOffTrailDays: Int
    @State private var accommodation: LookupItem?
    @State private var notesCharacterCount: Int = 0
    @State private var resupplied: Bool = false
    @State private var resupplyNotes: String
    
    enum FocusableViews: Hashable {
        case title
        case accommodation
        case notes
        case resupplyNotes
    }
    @FocusState private var focusedView: FocusableViews?
    
    
    init(checkIn: CheckIn?) {
        
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
        self.numberOfRestDays = checkInToEdit.numberOfRestDays
        self.numberOfOffTrailDays = checkInToEdit.numberOfOffTrailDays
        self.accommodation = LookupItem(id: "2", name: "Hotel", imageRotation: nil, imageName: "hotel") //checkInToEdit.accommodation
        self.resupplied = checkInToEdit.resupply ?? false
        self.resupplyNotes = checkInToEdit.resupplyNotes ?? ""
        
        self.accommodationList = []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack (alignment: .leading) {
                    TextField("Name of where you stayed", text: $title)
                        .styleBorderLight(focused: focusedView == .title)
                        .focused($focusedView, equals: .title)
                        .padding(.vertical)
                    
                    Button {
                        showAccommodationSelect = true
                    } label: {
                        HStack {
                            Image(systemName: accommodation?.sfSymbolName ?? "tent")
                            Text(accommodation?.name ?? "Tent")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .styleBorderLight()
                        .styleForegroundPrimary()
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
                        .styleBorderLight()
                        .styleForegroundPrimary()
                    }
                    .padding(.bottom)
                    
                    
                    AppTextEditor(text: $notes, placeholder: "Write something about your day :)")
                        .frame(height: 300)
                        .padding(.bottom)
                    
                    Section {
                        AppStepperManual(value: $distanceWalked, label: "Distance", minimumValue: 0, maximumValue: 100, unit: "km", systemImage: "figure.walk")
                        AppStepperManual(value: $numberOfRestDays, label: "Zero Days", maximumValue: 10, unit: "days", systemImage: "zzz")
                        AppStepperManual(value: $numberOfOffTrailDays, label: "Off Trail", maximumValue: 500, unit: "days", systemImage: "timer")
                    }
                    
                    Text("Resupply")
                        .font(.title)
                    
                    
                    Toggle(isOn: $resupplied) {
                        HStack {
                            Image(systemName: "shop")
                                .foregroundColor(.orange)
                            Text("Did you resupply here?")
                        }
                    }
                    .onChange(of: resupplied) { oldValue, newValue in
                        if newValue {
                            focusedView = .resupplyNotes
                        } else {
                            focusedView = nil
                        }
                    }
                    
                    
                    if resupplied {
                        TextEditor(text: $resupplyNotes)
                            .frame(height: 200)
                            .focused($focusedView, equals: .resupplyNotes)
                            .styleBorderLight(focused: focusedView == .resupplyNotes)
                    }
                }
            }
            .padding(.horizontal, 16)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .styleForegroundPrimary()
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
    EditCheckInView(checkIn: CheckIn.newWithDefaults)
    //EditCheckInView(checkIn: CheckIn.sample)
}
