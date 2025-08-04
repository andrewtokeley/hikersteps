//
//  CheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/07/2025.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var isPresentingEdit = false
    @State var showEditCheckIn = false
    @State var showDeleteConfirmation = false
    @State var showMenu = false
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    private var onDeleteRequest: ((CheckIn) -> Void )? = nil
    
    @Binding var checkIn: CheckIn
    var dayDescription: String
    
    init(checkIn: Binding<CheckIn>, dayDescription: String) {
        _checkIn = checkIn
        self.dayDescription = dayDescription
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                VStack {
                    ZStack {
                        HStack {
                            AppCircleButton(size: 30, imageSystemName: "ellipsis", rotationAngle: .degrees(90)) {
                                showMenu = true
                            }
                            .style(.filled)
                            
                            Spacer()
                            
                            AppCircleButton(size: 30,imageSystemName: "applepencil.gen1") {
                                isPresentingEdit = true
                            }
                            .style(.filled)
                        }
                        Text(dayDescription)
                            .font(.title2)
                        
                    }
                    
                    Text(checkIn.title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 2)
                    
                    Text(checkIn.date.formatted(.dateTime.weekday().day().month().year()))
                    
                    ZStack {
                        HStack {
                            Text("\(checkIn.distanceWalked)km").bold() + Text(" hike").foregroundColor(.gray)
                            Spacer()
                            Text("total ").foregroundColor(.gray) + Text("3226km").bold()
                        }
                        
                        if checkIn.accommodation != LookupItem.noSelection() {
                            VStack {
                                Image(systemName: checkIn.accommodation.imageName)
                                Text(checkIn.accommodation.name)
                            }
                        }
                        
                    }
                }
                //.frame(minHeight: 200)
                //.clipped()
                
                ScrollView {
                    VStack {
                        if checkIn.images.count > 0 {
                            if let imageUrl = checkIn.images[0].storageUrl {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.gray.opacity(0.1))
                                        .tint(.accentColor)
                                        .styleBorderLight(focused: true)
                                    
                                }
                            }
                        }
                        
                        Text(checkIn.notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }
                }
                .scrollBounceBehavior(.basedOnSize)

                Spacer()
                
                .sheet(isPresented: $isPresentingEdit) {
                    NavigationStack {
                        EditCheckInView(checkIn: $checkIn)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                    }
                }
                
                .confirmationDialog("Options", isPresented: $showMenu, titleVisibility: .hidden) {
                    Button("Share...") { /* edit */ }
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    Button("Cancel", role: .cancel) { }
                }
                
                .alert("Delete Entry", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    Button("Delete", role: .destructive) {
                        onDeleteRequest?(self.checkIn)
                    }
                } message: {
                    Text("Are you sure you want to delete this trail entry?")
                }
            }
            .padding()
//            .navigationTitle("CheckIn")
        }
    }
    func delete() {
        print("delete")
    }
    
    func onDeleteRequest(_ handler: ((CheckIn) -> Void)?) -> CheckInView {
        var copy = self
        copy.onDeleteRequest = handler
        return copy
    }
    func onNavigate(_ handler: @escaping (_ direction: NavigationDirection) -> Void) -> CheckInView {
        var copy = self
        copy.onNavigate = handler
        return copy
    }
}


#Preview {
    @Previewable @State var checkIn: CheckIn = CheckIn(id: "1", uid: "123", location: Coordinate.wellington.toCLLLocationCoordinate2D(), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: $checkIn, dayDescription: "Day 12")
}
