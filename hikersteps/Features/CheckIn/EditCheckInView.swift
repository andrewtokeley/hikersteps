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
    
    @FocusState private var focusedView: FocusableViews?
    
    private var onDelete: (()-> Void)? = nil
    private var onSaved: ((CheckIn) -> Void)? = nil
    
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
        // pass a copy of the checkin that we can edit before committing to the bound checkIn
        self.init(checkIn: checkIn, viewModel: ViewModel(checkIn: checkIn.wrappedValue))
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
                                Text("\(viewModel.checkIn.distanceWalked) km")
                                    .foregroundStyle(viewModel.checkIn.distanceWalked > 0 ? .primary : .secondary )
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
                    
                    AppImagePicker(image: image)
                        .padding(.bottom)
                    
                    AppTextEditor(text: $viewModel.checkIn.notes, placeholder: "Write something about your day :)")
                        .frame(height: 300)
                        .padding(.bottom)
                    
                    Text("Resupply")
                        .font(.title)
                    
                    Toggle(isOn: $viewModel.checkIn.resupply) {
                        HStack {
                            Image(systemName: "cart")
                                .foregroundColor(.orange)
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
                    
                    HStack {
                        Spacer()
                        Button("Delete") {
                            self.onDelete?()
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
                        // Save to firestore
                        viewModel.save { checkIn, error in
                            // copy the saved checkin to the bound checkIn
                            print("saved")
                            self.checkIn = checkIn
                            dismiss()
                            //...
                        }
                            
                        
                    }
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
                AppDateSelect(selectedDate: $viewModel.checkIn.date, title: "Check-In Date")
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium])
            }
            .presentationDetents([.medium])
            
            .sheet(isPresented: $showDistanceSelector) {
                // Need to handle units
                AppNumberPicker(title: "Distance Walked", number: $viewModel.checkIn.distanceWalked, units: [.km, .mi])
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
                viewModel.loadAccommodationLookups()
            }
        }
    }
    func onDelete(_ handler: @escaping (() -> Void)) -> EditCheckInView {
        var copy = self
        copy.onDelete = handler
        return copy
    }

}

#Preview {
    @Previewable @State var checkIn = CheckIn.sample
    EditCheckInView(checkIn: $checkIn, viewModel: EditCheckInView.ViewModelMock(checkIn: CheckIn.sample))
}
