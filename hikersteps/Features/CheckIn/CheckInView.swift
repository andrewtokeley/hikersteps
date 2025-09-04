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
    
    @State var isPresentingEdit = false
    @State var showEditCheckIn = false
    @State var showDeleteConfirmation = false
    @State var showMenu = false
    @State var showShareView = false
    @State var shareItems: [Any] = []
    @State var showImageFullScreen: Bool = false
    @Namespace private var animationNamespace
    
    private var onNavigate: ((_ direction: NavigationDirection) -> Void)? = nil
    private var onDeleteRequest: ((CheckIn) -> Void )? = nil
    
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
                VStack(alignment: .center) {
                    VStack {
                        ZStack {
                            HStack {
                                AppCircleButton(size: 30, imageSystemName: "ellipsis", rotationAngle: .degrees(90)) {
                                    showMenu = true
                                }
                                .style(.filled)
                                
                                Spacer()
                                
                                AppCircleButton(size: 30, imageSystemName: "square.and.arrow.up",bottomNudge: 3) {
                                    Task {
                                        let options = ShareOptions(
                                            viewportCentre: .checkIn,
                                            zoomLevel: 10,
                                            isShare: true)
                                        let share = await ShareActivities.createForJournal(username: auth.user.username, journalId: checkIn.journalId, checkIn: checkIn, shareOptions: options)
                                        self.shareItems = share.items
                                        self.showShareView = true
                                    }
                                }
                                .style(.filled)
                                
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
                            if checkIn.images.count > 0 {
                                if let imageUrl = checkIn.images[0].storageUrl {
                                    LazyImage(source: imageUrl) { state in
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
                                }
                            }
                            Text(checkIn.notes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    
                    if let sourceId = checkIn.id {
                        CommentStripView(source: .checkIn, sourceId: sourceId)
                    }
                    Spacer()
                    
                }
                .padding()
                
                .sheet(isPresented: $isPresentingEdit) {
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
                    if checkIn.images.count > 0 {
                        
                        Button("Make Cover Image") {
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
                
                .fullScreenCover(isPresented: $showImageFullScreen) {
                    if let imageUrl = checkIn.images[0].storageUrl {
                        if let url = URL(string: imageUrl) {
                            ZoomableImageViewer(url: url, isPresented: $showImageFullScreen)
                                .ignoresSafeArea()
                        }
                    }
                }
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
    @Previewable @State var checkIn: CheckIn = CheckIn(uid: "123", journalId: "1", id: "111", location: Coordinate.wellington, title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", distance: Measurement(value: 20, unit: UnitLength.kilometers), date: Date(), images: [StorageImage.sample])
    CheckInView(checkIn: $checkIn, dayDescription: "Day 13", totalDistanceToDate: Measurement(value: 1234,  unit: .kilometers))
        .environmentObject(AuthenticationManager.forPreview(metric: false))
}
