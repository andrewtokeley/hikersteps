//
//  Hike.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

/**
 The HikeView is the root view that shows the users checkins on a map with their trail.
 */
struct HikeView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    /// ViewModel to enable the view to access and persist model data.
    @StateObject var viewModel: ViewModel
    
    /// In-memory structure to manage checkins and navigation.
    @StateObject var checkInManager: CheckInManager = CheckInManager(checkIns: [])
    
    /// Created when a pin is dropped and user requests to create a new checkin
    @State var newCheckIn: CheckIn = CheckIn.nilValue
    
    @State var hasLoaded: Bool = false
    @State var navigateToStats: Bool = false
    @State var reOpenCheckInDetailsSheet: Bool = false
    
    /// Private flag to control when to show checkin sheet
    @State private var showCheckInDetails = false
    @State private var showAddCheckInSheet = false
    @State private var showEditCheckIn = false
    
    /// The hike this view is representing
    var hike: Journal

    /**
     Constructs a new HikeView from a hike instance and using the default ViewModel
     */
    init(hike: Journal) {
        let viewModel = ViewModel(checkInService: CheckInService(), hikeService: JournalService())
        self.init(hike: hike, viewModel: viewModel)
    }
    
    /**
     Construct a new HikeView, and pass in a ViewModel - used by previewer to use a mock service.
     */
    init(hike: Journal, viewModel: ViewModel) {
        self.hike = hike
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    /**
     Main View body
     */
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                let height = geometry.size.height
                let width = geometry.size.width
            
                ZStack {
                    MapView(
                        annotations: $checkInManager.annotations,
                        selectedAnnotationIndex: $checkInManager.selectedIndex,
                        annotationSafeArea: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 0.7 * height) ),
                        droppedPinAnnotation: $checkInManager.droppedPinAnnotation
                    )
                    .onMapTap { location in
                        self.checkInManager.clearSelectedCheckIn()
                        self.showCheckInDetails = false
                        self.showAddCheckInSheet = false
                        self.checkInManager.removeDropInAnnotation()
                    }
                    .onMapLongPress({ location in
                        self.checkInManager.addDropInAnnotation(location: location.coordinate)
                        showAddCheckInSheet = true
                        showCheckInDetails = false
                    })
                    .onDidSelectAnnotation({ annotation in
                        if let checkInId = annotation.checkInId {
                            self.checkInManager.move(.to(id: checkInId))
                            self.showCheckInDetails = true
                        }
                    })
                    .ignoresSafeArea()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToStats) {
            HikeDetailsView(hike: hike)
                .onDisappear {
                    if self.reOpenCheckInDetailsSheet {
                        self.showCheckInDetails = true
                    }
                }
        }
        .task {
            if !hasLoaded {
                if let uid = auth.loggedInUser?.uid {
                    Task {
                        do {
                            let checkIns = try await viewModel.loadCheckIns(uid: uid, hike: hike)
                            self.checkInManager.initialise(checkIns: checkIns)
                            
                            self.checkInManager.move(.latest)
                            self.hasLoaded = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showEditCheckIn) {
            if newCheckIn != CheckIn.nilValue {
                EditCheckInView(checkIn: $newCheckIn)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(.disabled)
            } else {
                EmptyView()
            }
        }
        
        .sheet(isPresented: $showAddCheckInSheet) {
            if let location = checkInManager.droppedPinAnnotation?.coordinate {
                NewCheckInDialog(journal: self.hike, proposedDate: checkInManager.nextAvailableDate, location: location)
                    .isDateAvailable({ date in
                        return checkInManager.isDateAvailable(date)
                    })
                    .onCancel {
                        self.checkInManager.removeDropInAnnotation()
                    }
                    // The user has selected a date and ready to create the entry
                    .onCreated() { newCheckIn in
                        self.checkInManager.addCheckIn(newCheckIn)
                        checkInManager.move(.to(id: newCheckIn.id!))
                        self.showEditCheckIn = true
                        self.checkInManager.removeDropInAnnotation()
                    }
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
            }
                
        }
        
        // Show CheckIn Detail Sheet
        .sheet(isPresented: $showCheckInDetails) {
            
            TabView(selection: $checkInManager.selectedIndex) {
                ForEach(Array(checkInManager.checkIns.enumerated()), id: \.element.id) { index, checkIn in
                    CheckInView(checkIn: $checkInManager.checkIns[index], dayDescription: checkInManager.dayDescription(checkInManager.checkIns[index]))
                        .onNavigate({ direction in
                            self.checkInManager.move(direction)
                        })
                        .onDeleteRequest({ checkIn in
                            if let id = checkIn.id {
                                self.checkInManager.removeCheckIn(id: id)
                                Task {
                                    do {
                                        try await self.viewModel.saveChanges(self.checkInManager)
                                    } catch {
                                        ErrorLogger.shared.log(error)
                                    }
                                }
                            }
                        })
                        .onHeroImageUpdated({ urlString in
                            if let id = self.hike.id {
                                Task {
                                    do {
                                        try await viewModel.updateHeroImage(hikeId: id, urlString: urlString)
                                    } catch {
                                        ErrorLogger.shared.log(error)
                                    }
                                }
                            }
                        })
                        .onDisappear {
                            self.reOpenCheckInDetailsSheet = false
                        }
                        .tag(index)
                    
                    
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .presentationDetents([.height(255), .large])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
            .presentationBackgroundInteraction(.enabled)
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppBackButton()
                    .willDismiss {
                        self.showCheckInDetails = false
                    }
            }
            ToolbarItem(placement: .topBarTrailing) {
                AppCircleButton(imageSystemName: "chevron.right")
                        .style(.filledOnImage)
                        .onClick { 
                            if self.showCheckInDetails {
                                self.reOpenCheckInDetailsSheet = true
                            }
                            self.showCheckInDetails = false
                            self.navigateToStats = true
                        }
            }
        }
    }
}

#Preview {
    let authMock = AuthenticationManagerMock() as AuthenticationManager
    HikeView(hike: Journal.nilValue,
             viewModel: HikeView.ViewModel(checkInService: CheckInService.Mock(), hikeService: JournalService.Mock())
        )
        .environmentObject(authMock)
}
