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
        
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    
    @Binding var checkIn: CheckIn
    var dayDescription: String
    
    init(checkIn: Binding<CheckIn>, dayDescription: String) {
        _checkIn = checkIn
        self.dayDescription = dayDescription
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                
                    ZStack {
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
                        Text(dayDescription)
                            .font(.title2)
                    
                    }.padding(.top)
                
                Text(checkIn.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                NavigationStripView {
                    Text(checkIn.date.formatted(.dateTime.weekday().day().month().year()))
                }
                .onNavigate { direction in
                    // pass on to parent view
                    self.onNavigate?(direction)
                }
                
                Divider()
                
                // Stats
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
                .padding(.top)
                .frame(height: 30)
                
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
                    
                    Text(checkIn.notes)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    
                    
                    Spacer()
                }
                .padding(.top)
                .sheet(isPresented: $isPresentingEdit) {
                    NavigationStack {
                        EditCheckInView(checkIn: $checkIn)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                    }
                }
            }
            .padding()
//            .navigationTitle("CheckIn")
        }
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
    @Previewable @State var checkIn: CheckIn = CheckIn(id: "1", uid: "123", location: Coordinate.wellington.toCLLLocationCoordinate2D(), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: $checkIn, dayDescription: "Day 12")
}
