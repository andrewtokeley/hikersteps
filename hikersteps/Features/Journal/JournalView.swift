//
//  Hike.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI
import FirebaseAuth

/**
 The JournalView is the root view that shows the users checkins on a map with their trail.
 */
struct JournalView: View {
    @EnvironmentObject var auth: AuthenticationManager
    
    @State private var selectedDetent: PresentationDetent = .medium
    
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
    
    /// The Journal that is being viewed
    var journal: Journal

    /**
     Constructs a new JournalView from a Journal instance and using the default ViewModel
     */
    init(journal: Journal) {
        let viewModel = ViewModel(checkInService: CheckInService(), journalService: JournalService())
        self.init(journal: journal, viewModel: viewModel)
    }
    
    /**
     Construct a new JournalView, and pass in a ViewModel - used by previewer to inject a mock service.
     */
    init(journal: Journal, viewModel: ViewModel) {
        self.journal = journal
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
                        
                        // add a temporary checkIn to populate for the new entry
                        if let hikeId = self.journal.id {
                            self.newCheckIn = CheckIn(uid: auth.user.uid, adventureId: hikeId, location: location.coordinate, date: checkInManager.nextAvailableDate)
                            showAddCheckInSheet = true
                            showCheckInDetails = false
                        } else {
                            print("unaith")
                        }
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
            JournalDetailsView(journal: journal)
                .onDisappear {
                    if self.reOpenCheckInDetailsSheet {
                        self.showCheckInDetails = true
                    }
                }
        }
        .task {
            if !hasLoaded {
                Task {
                    do {
                        let checkIns = try await viewModel.loadCheckIns(uid: auth.user.uid, journal: journal)
                        if checkIns.isEmpty == false {
                            self.checkInManager.initialise(checkIns: checkIns)
                            self.checkInManager.move(.latest)
                            self.showCheckInDetails = true
                        }
                        self.hasLoaded = true
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditCheckIn) {
            EditCheckInView(checkIn: $checkInManager.selectedCheckIn)
                .onDisappear {
                    if self.reOpenCheckInDetailsSheet {
                        self.showCheckInDetails = true
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.disabled)
        }
        
        .sheet(isPresented: $showAddCheckInSheet) {
            EditCheckInView(checkIn: $newCheckIn)
                .onSaved({
                    self.checkInManager.addCheckIn(newCheckIn)
                    checkInManager.move(.to(id: newCheckIn.id!))
                    self.checkInManager.removeDropInAnnotation()
                    
                    // after we've edited we want to show the view sheet
                    self.reOpenCheckInDetailsSheet = true
                })
                .onDisappear {
                    self.showCheckInDetails = true
                }
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
                .presentationBackgroundInteraction(.disabled)
//            if let location = checkInManager.droppedPinAnnotation?.coordinate {
//                NewCheckInDialog(journal: self.hike, proposedDate: checkInManager.nextAvailableDate, location: location)
//                    .isDateAvailable({ date in
//                        return checkInManager.isDateAvailable(date)
//                    })
//                    .onCancel {
//                        self.checkInManager.removeDropInAnnotation()
//                    }
//                    // A new checkIn has been created
//                    .onCreated() { newCheckIn in
//                        self.checkInManager.addCheckIn(newCheckIn)
//                        checkInManager.move(.to(id: newCheckIn.id!))
//                        self.checkInManager.removeDropInAnnotation()
//                        // after we've edited we want to show the view sheet
//                        self.reOpenCheckInDetailsSheet = true
//                        self.showEditCheckIn = true
//                        
//                    }
//                .presentationDetents([.fraction(0.5), .large])
//                .presentationDragIndicator(.visible)
//                .interactiveDismissDisabled(true)
//                .presentationBackgroundInteraction(.enabled)
//            }
                
        }
        
        // Show CheckIn Detail Sheet
        .sheet(isPresented: $showCheckInDetails) {
            
            TabView(selection: $checkInManager.selectedIndex) {
                ForEach(Array(checkInManager.checkIns.enumerated()), id: \.element.id) { index, checkIn in
                    CheckInView(checkIn: $checkInManager.checkIns[index], dayDescription: checkInManager.dayDescription(checkInManager.checkIns[index]), totalDistanceDescription: journal.statistics.totalDistanceWalked.description)
                        .onNavigate({ direction in
                            self.checkInManager.move(direction)
                        })
                        .onDeleteRequest({ checkIn in
                            if let id = checkIn.id {
                                self.checkInManager.removeCheckIn(id: id)
                                Task {
                                    do {
                                      try await self.viewModel.deleteCheckIn(checkIn)
                                    } catch {
                                        ErrorLogger.shared.log(error)
                                    }
                                }
                            }
                        })
                        .onHeroImageUpdated({ urlString in
                            if let id = self.journal.id {
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
    JournalView(journal: Journal.sample,
             viewModel: JournalView.ViewModel(checkInService: CheckInService.Mock(), journalService: JournalService.Mock())
        )
    .environmentObject(AuthenticationManager(
        authProvider: AuthProviderMock(),
        userService: UserService.Mock(),
        userSettingsService: UserSettingsService.Mock()))
}
