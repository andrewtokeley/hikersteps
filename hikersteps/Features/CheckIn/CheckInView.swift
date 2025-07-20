//
//  CheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/07/2025.
//

import SwiftUI

struct CheckInView: View {
    @Binding var checkIn: CheckIn?
    @Environment(\.dismiss) private var dismiss
    @State var isPresentingEdit = false
    @State var showEditCheckIn = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(checkIn?.title ?? "Check In")
                        .font(.title2)
                        .fontWeight(.bold)
                    
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
                Text("Day 12 ").bold() + Text(checkIn!.date.formatted(.dateTime.day().month().year())).foregroundColor(.gray)
                
                // Stats
                HStack {
                    Text("26km").bold() + Text(" hike").foregroundColor(.gray)
                    Spacer()
                    Text("total ").foregroundColor(.gray) + Text("3226km").bold()
                }
                .padding(.top)
                
                ScrollView {
                    if checkIn!.images.count > 0 {
                        if let imageUrl = checkIn?.images[0].storageUrl {
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray
                            }
                            .padding(.top)
                        }
                    }
                    Text(checkIn?.notes ?? "-")
                        .padding(.top)
                }
                Spacer()
            }
            .padding()
            .sheet(isPresented: $isPresentingEdit) {
                NavigationStack {
                    EditCheckInView(checkIn: checkIn)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled(true)
                }
            }
        }
        .navigationTitle("CheckIn")
        
    }
}

#Preview {
    @Previewable @State var checkIn: CheckIn? = CheckIn(uid: "123", locationAsGeoPoint: Coordinate.wellington.toGeoPoint(), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: $checkIn)
}
