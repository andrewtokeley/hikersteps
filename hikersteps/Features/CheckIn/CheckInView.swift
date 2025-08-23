//
//  CheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/07/2025.
//

import SwiftUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthenticationManager

    @Binding var checkIn: CheckIn
    
    @State var isPresentingEdit = false
    @State var showEditCheckIn = false
    @State var showDeleteConfirmation = false
    @State var showMenu = false
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    private var onDeleteRequest: ((CheckIn) -> Void )? = nil
    
    private var onHeroImageUpdated: ((String) -> Void)? = nil
    
    
    var dayDescription: String
    var totalDistanceDescription: String
    
    init(checkIn: Binding<CheckIn>, dayDescription: String, totalDistanceDescription: String) {
        _checkIn = checkIn
        self.dayDescription = dayDescription
        self.totalDistanceDescription = totalDistanceDescription
        
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                            Text(checkIn.date.formatted(.dateTime.weekday().day().month().year()))
                                .font(.title2)
                            
                        }
                        
                        Text(checkIn.title)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 2)
                        Text(auth.userSettings.preferredDistanceUnit.properName)
                        Text(dayDescription)
                        
                        ZStack {
                            HStack {
                                Text(checkIn.distance.convertTo(auth.userSettings.preferredDistanceUnit).description).bold() + Text(" hike").foregroundColor(.gray)
                                Spacer()
                                Text("total ").foregroundColor(.gray) + Text(totalDistanceDescription).bold()
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
                                            .frame(maxWidth: geometry.size.width-30)
                                            .clipped()
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .frame(height: 200)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .tint(.accentColor)
                                            .styleBorderLight(focused: true)
                                        
                                    }
                                    .frame(maxWidth: .infinity)
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
                                    .presentationDragIndicator(.hidden)
                                    .interactiveDismissDisabled(true)
                            }
                        }
                    
                        .confirmationDialog("Options", isPresented: $showMenu, titleVisibility: .hidden) {
                            Button("Share...") { /* edit */ }
                            if checkIn.images.count > 0 {
                                
                                Button("Use Image for Journal Title") {
                                    if let url = checkIn.images.first?.storageUrl {
                                        self.onHeroImageUpdated?(url)
                                    }
                                }
                            }
                            Button("Delete Entry", role: .destructive) {
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
            }
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
    func onHeroImageUpdated(_ handler: ((_ urlString: String) -> Void)?) -> CheckInView {
        var copy = self
        copy.onHeroImageUpdated = handler
        return copy
    }
    
}


#Preview {
    @Previewable @State var checkIn: CheckIn = CheckIn(uid: "123", adventureId: "1", id: "111", location: Coordinate.wellington, title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", distance: DistanceUnit(20, .km), date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: $checkIn, dayDescription: "Day 13", totalDistanceDescription: "1234")
        .environmentObject(AuthenticationManager.forPreview())
}
