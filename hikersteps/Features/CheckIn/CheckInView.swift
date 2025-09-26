//
//  CheckInView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 05/07/2025.
//

import SwiftUI
import NukeUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthenticationManager

    @Binding var checkIn: CheckIn
    
    @State private var isPresentingEdit = false
    @State private var showEditCheckIn = false
    @State private var showDeleteConfirmation = false
    @State private var showMenu = false
    @State private var showShareView = false
    @State private var shareItems: [Any] = []
    @State private var showImageFullScreen: Bool = false
    
    @State private var socialContext: SocialContext?
    
    @Namespace private var animationNamespace
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    private var onDeleteRequest: ((CheckIn) -> Void )? = nil
    private var onEditRequest: ((CheckIn) -> Void )? = nil
    
    private var onHeroImageUpdated: ((String) -> Void)? = nil
    
    var dayDescription: String
    var totalDistanceToDate: Measurement<UnitLength>
    
    init(checkIn: Binding<CheckIn>, dayDescription: String, totalDistanceToDate: Measurement<UnitLength>) {
        _checkIn = checkIn
        self.dayDescription = dayDescription
        self.totalDistanceToDate = totalDistanceToDate
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    VStack(alignment: .center) {
                        VStack {
                            ZStack {
                                HStack {
                                    AppCircleButton(size: 30, imageSystemName: "ellipsis", rotationAngle: .degrees(90)) {
                                        onEditRequest?(checkIn)
                                    }
                                    .style(.filled)
                                    
                                    Spacer()
                                    
                                    AppCircleButton(size: 30,imageSystemName: "applepencil.gen1") {
                                        isPresentingEdit = true
                                    }
                                    .style(.filled)
                                    .padding(.leading, 5)
                                }
                                // centred in ZStack
                                Text(checkIn.date.formatted(.dateTime.weekday().day().month().year()))
                                    .font(.title3)
                            }
                            
                            Text(checkIn.title)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.bottom, 2)
                            
                            
                            ZStack {
                                HStack(alignment: .center) {
                                    Text(checkIn.distanceWalked.converted(to: auth.userSettings.preferredDistanceUnit).formatted(dp: 0)).bold() + Text(" day").foregroundColor(.gray)
                                    Spacer()
                                    Text("total ").foregroundColor(.gray) + Text(totalDistanceToDate.converted(to: auth.userSettings.preferredDistanceUnit).formatted(dp: 0)).bold()
                                }
                                Text(dayDescription)
                                    .font(.title3)
                            }
                        }
                        
                        ScrollView {
                            VStack {
                                
                                if checkIn.hasImage {
                                    VStack {
                                        LazyImage(source: checkIn.image.storageUrl) { state in
                                            if let image = state.image {
                                                image
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(height: 200)
                                                    .frame(maxWidth: geometry.size.width-30)
                                                    .clipped()
                                                    .cornerRadius(10)
                                                    .onTapGesture {
                                                        withAnimation(.spring()) {
                                                            showImageFullScreen = true
                                                        }
                                                    }
                                            } else if state.error != nil {
                                                Color.red // Error state
                                            } else {
                                                ProgressView()
                                                    .scaleEffect(1.2)
                                                    .frame(height: 200)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                    .background(Color.gray.opacity(0.1))
                                                    .tint(.accentColor)
                                                    .styleBorderLight(focused: true)
                                            }
                                        }
                                        Text(checkIn.image.caption)
                                            .font(.caption)
                                            .padding(.bottom)
                                    }
                                }
                                Text(checkIn.notes)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top)
                                
                            }
                            .opacity(contentOpacity(geometry))
                            
                        }
                        .scrollBounceBehavior(.basedOnSize)
                        // this number just needs to be bigger than the medium sized sheet
                        // we only want scrolling in full height sheet
                        .scrollDisabled(geometry.size.height < 500)
                        
                        HStack {
                            if let context = self.socialContext {
                                CommentStripView(socialContext: context)
                            }
                        }
                    }
                    .padding()
                }
                
                .fullScreenCover(isPresented: $isPresentingEdit) {
                    NavigationStack {
                        EditCheckInView(checkIn: $checkIn)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.hidden)
                            .interactiveDismissDisabled(true)
                    }
                }
                
                .sheet(isPresented: $showShareView) {
                    ShareSheet(activityItems: shareItems)
                }
                
                .confirmationDialog("Options", isPresented: $showMenu, titleVisibility: .hidden) {
                    if checkIn.image.hasImage {
                        
                        Button("Make Cover Image") {
                            self.onHeroImageUpdated?(checkIn.image.storageUrl)
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
                
                .fullScreenCover(isPresented: $showImageFullScreen) {
                    if checkIn.image.hasImage {
                        if let url = URL(string: checkIn.image.storageUrl) {
                            ZoomableImageViewer(url: url, isPresented: $showImageFullScreen)
                                .ignoresSafeArea()
                        }
                    }
                }
                .onAppear {
                    self.socialContext = SocialContext(source: .checkIn, sourceId: checkIn.id!, auth: auth)
                }
            }
        }
    }
    
    func contentOpacity(_ geometry: GeometryProxy) -> Double {
        guard geometry.size.height < 400 else { return 1 }
        let min = 250.0, max = 400.0
        return  (geometry.size.height - min) / (max - min)
    }
    
    func delete() {
        print("delete")
    }
    
    func onEditRequest(_ handler: ((CheckIn) -> Void)?) -> CheckInView {
        var copy = self
        copy.onEditRequest = handler
        return copy
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
    @Previewable @State var checkIn: CheckIn = CheckIn(uid: "123", journalId: "1", id: "111", location: Coordinate.wellington, title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", distance: Measurement(value: 20, unit: UnitLength.kilometers), date: Date(), images: [StorageImage.sample])
    
    CheckInView(checkIn: $checkIn, dayDescription: "Day 13", totalDistanceToDate: Measurement(value: 1234,  unit: .kilometers))
        .environmentObject(AuthenticationManager.forPreview(metric: false))
}
