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
    @State var newCheckIn: CheckIn?
    
    @State var hasLoaded: Bool = false
    @State var navigateToStats: Bool = false
    
    /// Private flag to control when to show checkin sheet
    @State private var showCheckInDetails = false
    @State private var showAddCheckInSheet = false
    
    /// The hike this view is representing
    var hike: Hike

    /**
     Constructs a new HikeView from a hike instance and using the default ViewModel
     */
    init(hike: Hike) {
        let viewModel = ViewModel(checkInService: CheckInService(), hikeService: HikerService())
        self.init(hike: hike, viewModel: viewModel)
    }
    
    /**
     Construct a new HikeView, and pass in a ViewModel - used by previewer to use a mock service.
     */
    init(hike: Hike, viewModel: ViewModel) {
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
                        self.checkInManager.addDropInAnnotation(location: location)
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
            HikeStatisticsView(hike: hike)
        }
        .task {
            if !hasLoaded {
                if let uid = auth.loggedInUser?.uid {
                    Task {
                        do {
                            let checkIns = try await viewModel.loadCheckIns(uid: uid, hike: hike)
                            self.checkInManager.initialise(checkIns: checkIns)
                            
                            self.checkInManager.move(.start)
                            self.hasLoaded = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .sheet(item: $newCheckIn) { checkIn in
            EditCheckInView(checkIn: Binding(get: {newCheckIn!}, set: {newCheckIn = $0}))
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
        }
        
        .sheet(isPresented: $showAddCheckInSheet) {
            NewCheckInDialog()
                .onCancel {
                    self.checkInManager.removeDropInAnnotation()
                }
                .onConfirm {
                    if let uid = auth.loggedInUser?.uid, let location = checkInManager.droppedPinAnnotation?.coordinate {
                        let new = self.checkInManager.addCheckIn(uid: uid, location: location , date: Date())
                        self.newCheckIn = new
                    }
                    self.checkInManager.removeDropInAnnotation()
                }
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
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
                                        ErrorLogger.shared.log(error, context: "HikeView:onDeleteRequest")
                                    }
                                }
                            }
                        })
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
                AppCircleButton(imageSystemName: "chart.bar")
                        .style(.filledOnImage)
                        .onClick {
                            self.showCheckInDetails = false
                            self.navigateToStats = true
                        }
            }
        }
    }
}

#Preview {
    let authMock = AuthenticationManagerMock() as AuthenticationManager
    HikeView(hike: Hike(),
        viewModel: HikeView.ViewModel(checkInService: CheckInServiceMock(), hikeService: HikerServiceMock())
        )
        .environmentObject(authMock)
}
