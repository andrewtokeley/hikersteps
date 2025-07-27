//
//  CheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/07/2025.
//

import SwiftUI

struct CheckInView: View {
    var checkIn: CheckIn
    @Environment(\.dismiss) private var dismiss
    @State var isPresentingEdit = false
    @State var showEditCheckIn = false
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    
    init(checkIn: CheckIn, onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil) {
        self.checkIn = checkIn
        self.onNavigate = onNavigate
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        isPresentingEdit = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.medium)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(.lightGray))
                            .padding(.trailing)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.medium)
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(Color(.lightGray))
                    }
                }
                .padding(.top)
                
                Text("Day 1")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(checkIn.title ?? "Check In")
                    .font(.title)
                    .fontWeight(.bold)
                
                
                
                NavigationStripView {
                    Text(checkIn.date.formatted(.dateTime.day().month().year()))
                }
                .onNavigate { direction in
                    // pass on to parent view
                    onNavigate?(direction)
                }
                
                // Stats
                HStack {
                    Text("26km").bold() + Text(" hike").foregroundColor(.gray)
                    Spacer()
                    Text("total ").foregroundColor(.gray) + Text("3226km").bold()
                }
                .padding(.top)
                
                ScrollView {
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
                    
                    if let notes = checkIn.notes {
                        Text(notes)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top)
                    }
//                    Color(.blue)
                }
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isPresentingEdit) {
                NavigationStack {
                    EditCheckInView(checkIn: checkIn, onDeleteRequest: delete)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled(true)
                }
            }
        }
        .navigationTitle("CheckIn")
        
    }
    func delete() {
        print("delete")
    }
    
    func onNavigate(_ handler: @escaping (_ direction: NavigationDirection) -> Void) -> CheckInView {
        var copy = self
        copy.onNavigate = handler
        return copy
    }
}

#Preview {
    @Previewable @State var checkIn: CheckIn = CheckIn(uid: "123", locationAsGeoPoint: Coordinate.wellington.toGeoPoint(), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: checkIn)
}
