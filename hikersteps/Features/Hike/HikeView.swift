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
    
    /// Private flag to control when to show checkin sheet
    @State private var showCheckInDetails = false
    
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
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            
            NavigationStack {
                ZStack {
                    MapView(
                        annotations: $checkInManager.annotations,
                        selectedAnnotationIndex: $checkInManager.selectedIndex,
                        annotationSafeArea: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 0.7 * height) )
                    )
                    .onMapTap { location in
                        self.showCheckInDetails = false
                    }
                    .onMapLongPress({ location in
                        print("long map tap")
                    })
                    .onDidSelectAnnotation({ annotation in
                        if let checkInId = annotation.checkInId {
                            self.checkInManager.move(.to(id: checkInId))
                            self.showCheckInDetails = true
                        }
                    })
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if let uid = auth.loggedInUser?.uid {
                            viewModel.loadCheckIns(uid: uid, hike: hike) { checkIns in
                                self.checkInManager.checkIns = checkIns
                                self.checkInManager.move(.start)
                            }
                        }
                    }
                }
            }
        }
        // Show CheckIn Detail Sheet
        .sheet(isPresented: $showCheckInDetails) {
            if let checkIn = checkInManager.selectedCheckIn {
                
                CheckInView(checkIn: checkIn)
                    .onNavigate({ direction in
                        self.checkInManager.move(direction)
                    })
                    .presentationDetents([.fraction(0.3), .large])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(.enabled)
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                AppBackButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                AppCircleButton(imageSystemName: "add.circle")
            }
        }
    }
}

#Preview {
    let mock = AuthenticationManagerMock() as AuthenticationManager
    HikeView(
        viewModel: HikeView.ViewModelMock(),
        hike: Hike(description: "Walking the length of Aotearoa", name: "Te Araroa 2021/22", uid: "1"))
        .environmentObject(mock)
}
