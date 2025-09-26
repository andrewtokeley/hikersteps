//
//  Hike.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI
import FirebaseAuth

enum JournalViewMode {
    case map
    case tiles
}

enum CheckInSheetHeight {
    case small
    case medium
    case large
    
    var detent: PresentationDetent {
        switch self {
        case .small:
            return .height(240)
        case .medium:
            return .height(460)
        case .large:
            return .large
        }
    }
    
    var height: CGFloat? {
        switch self {
        case .small: return 240
        case .medium: return 460
        case .large: return nil
        }
    }
}
/**
 The JournalView is the root view that shows the users checkins on a map with their trail.
 */
struct JournalView: View {
    @EnvironmentObject var auth: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
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
    
    @State private var showCheckInDetails = false
    @State private var showAddCheckInSheet = false
    @State private var showEditCheckIn = false
    @State private var showDeleteConfirmation = false
    @State private var showJournalMenu = false
    @State private var showEditJournal = false
    
    
    /// Flag to let the view that an async process is running
    @State private var isWorking = false
    
    /// The Journal that is being viewed
    @State private var journal: Journal

    @State private var viewMode: JournalViewMode = .map
    @State private var defaultCheckInSheetHeight: PresentationDetent
    @State var checkInSheetHeight: CGFloat
    
    /**
     Constructs a new JournalView from a Journal instance and using the default ViewModel
     */
    init(journal: Journal) {
        let viewModel = ViewModel(checkInService: CheckInService(), journalService: JournalService(), userSettingsService: UserSettingsService())
        self.init(journal: journal, viewModel: viewModel)
    }
    
    /**
     Construct a new JournalView, and pass in a ViewModel - used by previewer to inject mock services.
     */
    init(journal: Journal, viewModel: ViewModel) {
        self.journal = journal
        _viewModel = StateObject(wrappedValue: viewModel)
//        _defaultCheckInSheetHeight = State(wrappedValue: .fraction(0.6))
        _defaultCheckInSheetHeight = State(wrappedValue: .height(240))
        _checkInSheetHeight = State(wrappedValue: 240)
    }
    
    /**
     Main View body
     */
    var body: some View {
        NavigationStack {
            ZStack {
                MapView(
                    annotations: $checkInManager.annotations,
                    selectedAnnotationIndex: $checkInManager.selectedIndex,
                    bottomPadding: $checkInSheetHeight,
                    droppedPinAnnotation: $checkInManager.droppedPinAnnotation
                )
                .onMapTap { location in
                    
                    self.checkInManager.clearSelectedCheckIn()

                    self.showCheckInDetails = false
                    self.checkInSheetHeight = 0
                    
                    self.showAddCheckInSheet = false
                    self.checkInManager.removeDropInAnnotation()
                }
                .onPuckTap({ location in
                    //
                })
                .onMapLongPress({ location in
                    self.dropPinForAdd(location: location.coordinate)
                })
                .onDidSelectAnnotation({ annotation in
                    if let checkInId = annotation.checkInId {
                        self.checkInManager.move(.to(id: checkInId))
                        if !self.showCheckInDetails {
                            defaultCheckInSheetHeight = CheckInSheetHeight.medium.detent
                            checkInSheetHeight = CheckInSheetHeight.medium.height!
                        }
                        self.showCheckInDetails = true
                    }
                })
                .ignoresSafeArea()
                .opacity( viewMode == .map ? 1 : 0)
                
                VStack {
                    DayGrid(checkIns: $checkInManager.checkIns, selectedIndex: $checkInManager.selectedIndex)
                        .onSelected { checkIn in
                            if let id = checkIn.id {
                                self.checkInManager.move(.to(id: id))
                                self.showCheckInDetails = true
                            }
                        }
                }
                .opacity( viewMode == .tiles ? 1 : 0)
                
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
                        
                        // update the lastJournalId
                        auth.userSettings.lastJournalId = journal.id
                        try await viewModel.updateUserSettings(settings: auth.userSettings)

                        
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditJournal) {
            EditJournalView(journal: $journal)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.disabled)
            
        }
        
        .sheet(isPresented: $showAddCheckInSheet) {
            EditCheckInView(checkIn: $newCheckIn)
                .onSaved({ success in
                    if success {
                        self.checkInManager.addCheckIn(newCheckIn)
                        checkInManager.move(.to(id: newCheckIn.id!))
                        self.showCheckInDetails = true
                    } else {
                        // failed to save
                    }
                    self.checkInManager.removeDropInAnnotation()
                })
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
                .presentationBackgroundInteraction(.disabled)
        }
        
        // Show CheckIn Detail Sheet
        .sheet(isPresented: $showCheckInDetails) {
            GeometryReader { proxy in
                TabView(selection: $checkInManager.selectedIndex) {
                    ForEach(Array(checkInManager.checkIns.enumerated()), id: \.element.id) { index, checkIn in
                        
                        CheckInView(
                            checkIn: $checkInManager.checkIns[index],
                            dayDescription: checkInManager.dayDescription(checkInManager.checkIns[index]),
                            totalDistanceToDate: checkInManager.distanceToDate(checkInManager.checkIns[index]))  /*journal.statistics.totalDistanceWalked(at: checkInManager.checkIns[index]))*/
                        .onNavigate({ direction in
                            self.checkInManager.move(direction)
                        })
                        .onEditRequest( { checkIn in
                            self.showEditCheckIn = true
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
                .presentationDetents([
                    CheckInSheetHeight.small.detent,
                    CheckInSheetHeight.medium.detent,
                    CheckInSheetHeight.large.detent]
                    ,selection: $defaultCheckInSheetHeight)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
                .presentationBackground(Color.adaptive(light: .white, dark: .black))
                .onDisappear {
                    withAnimation {
                        checkInSheetHeight = 0
                    }
                }
                .onChange(of: defaultCheckInSheetHeight) { old, new in
                    withAnimation {
                        if new == CheckInSheetHeight.small.detent {
                            checkInSheetHeight = CheckInSheetHeight.small.height!
                        } else if new == CheckInSheetHeight.medium.detent {
                            checkInSheetHeight = CheckInSheetHeight.medium.height!
                        }
                    }
                }
            }
        }
        
        .fullScreenCover(isPresented: $showEditCheckIn) {
            EditCheckInView(checkIn: $checkInManager.selectedCheckIn)
        }
        .confirmationDialog("Journal", isPresented: $showJournalMenu, titleVisibility: .hidden) {
            
            Button("Go to Start") {
                self.checkInManager.move(.start)
                self.showCheckInDetails = true
            }
            Button("Got to Latest") {
                self.checkInManager.move(.latest)
                self.showCheckInDetails = true
            }
            
            Button("Edit Journal") {
                self.showEditJournal = true
            }
            
            Button("Delete Journal", role: .destructive) {
                self.showDeleteConfirmation = true
            }
            Button("Cancel", role: .cancel) { }
        }
        
        .alert("Delete Journal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        self.isWorking = true
                        try await viewModel.deleteJournal(journal: self.journal)
                        self.isWorking = false
                        dismiss()
                    } catch {
                        self.isWorking = false
                        ErrorLogger.shared.log(error)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this Journal, including all photos and journal entries? You can't undo this action!")
        }
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if (viewMode == .map ) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppCircleButton(imageSystemName: "square.grid.2x2") {
                        self.viewMode = .tiles
                    }
                    .style(.filledOnImage)
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppCircleButton(imageSystemName: "map") {
                        self.viewMode = .map
                    }
                    .style(.plain)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                AppCircleButton(imageSystemName: "ellipsis", rotationAngle: .degrees(90))
                    .style(self.viewMode == .map ? .filledOnImage : .plain)
                    .onClick {
                        self.showJournalMenu = true
                    }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                AppCircleButton(imageSystemName: "xmark")
                    .style(self.viewMode == .map ? .filledOnImage : .plain)
                    .onClick {
                        self.showCheckInDetails = false
                        dismiss()
                    }
            }
            
        }
    }
    
    func dropPinForAdd(location: Coordinate) {
        self.checkInManager.addDropInAnnotation(location: location)
        
        // add a temporary checkIn to populate for the new entry
        if let journalId = self.journal.id {
            self.newCheckIn = CheckIn(uid: auth.user.uid, journalId: journalId, location: location, date: checkInManager.nextAvailableDate)
            showAddCheckInSheet = true
            showCheckInDetails = false
        } else {
            // something went wrong
            self.checkInManager.removeDropInAnnotation()
        }
    }
}

#Preview {
    NavigationStack {
        JournalView(journal: Journal.sample,
                    viewModel: JournalView.ViewModel(checkInService: CheckInService.Mock(), journalService: JournalService.Mock(), userSettingsService: UserSettingsService.Mock())
        )
        .environmentObject(AuthenticationManager.forPreview(metric: false))
    }
}
