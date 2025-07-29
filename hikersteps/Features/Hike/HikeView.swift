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
    @StateObject var viewModel: ViewModel = ViewModel()
    
    /// In-memory structure to manage checkins and navigation.
    @StateObject var checkInManager: CheckInManager = CheckInManager(checkIns: [])
    
    /// Created when a pin is dropped and user requests to create a new checkin
    @State var newCheckIn: CheckIn?
    
    /// Private flag to control when to show checkin sheet
    @State private var showCheckInDetails = false
    @State private var showAddCheckInSheet = false
    
    /// The hike this view is representing
    var hike: Hike

    /**
     Constructs a new HikeView from hike instance
     */
    init(hike: Hike) {
        self.hike = hike
    }
    
    /**
     Used by the Preview to inject a mock ViewModel and Hike instances
     */
    init(viewModel: ViewModel, hike: Hike) {
        self.init(hike: hike)
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
                        self.showCheckInDetails = false
                    }
                    .onMapLongPress({ location in
                        self.checkInManager.addDropInAnnotation(location: location)
                        showAddCheckInSheet = true
                        showCheckInDetails = false
                    })
                    .onDidSelectAnnotation({ annotation in
                        if let checkInId = annotation.checkInId {
                            print("move: onDidSelectAnnotation")
                            self.checkInManager.move(.to(id: checkInId))
                            self.showCheckInDetails = true
                        }
                    })
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let uid = auth.loggedInUser?.uid {
                            viewModel.loadCheckIns(uid: uid, hike: hike) { checkIns in
                                // initialise the checkInMananger
                                self.checkInManager.initialise(checkIns: checkIns)
                                print("move: onAppear")
                                self.checkInManager.move(.start)
                            }
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
                
            CheckInView(checkIn: $checkInManager.selectedCheckIn, dayDescription: checkInManager.dayDescription(checkInManager.selectedCheckIn))
                .onNavigate({ direction in
                    print("move: onNavigate")
                    self.checkInManager.move(direction)
                })
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
        
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppBackButton()
            }
        }
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    HikeView(
        viewModel: HikeView.ViewModelMock(),
        hike: Hike(description: "fWalking the length of Aotearoa", name: "Te Araroa 2021/22", uid: "1"))
        .environmentObject(mock)
}
