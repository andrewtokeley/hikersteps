//
//  MapNew.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 24/07/2025.
//

import SwiftUI
import MapboxMaps

struct MapView: View {
    @Binding var checkIns: [CheckIn]
    
    // ViewModel
    @StateObject private var viewModel = ViewModel()
    
    @State private var selectedCheckIn: CheckIn?
    @State private var showDetail: Bool = false
    @State private var showNewCheckInView: Bool = false
    @State private var showEditCheckIn: Bool = false
    @State private var newCheckIn: CheckIn?
    
    @State private var viewport = Viewport.camera(center: .init(latitude: Coordinate.wellington.latitude, longitude: Coordinate.wellington.longitude), zoom: 10, bearing: 0, pitch: 0)
    
    init(checkIns: Binding<[CheckIn]>) {
        _checkIns = checkIns
        _selectedCheckIn = State(initialValue: checkIns.first?.wrappedValue)
    }
    
    var body: some View {
        MapReader { _ in
            Map(viewport: $viewport) {
                
                // Display checkins
                ForEvery(self.checkIns, id: \.id) { checkIn in
                    MapViewAnnotation(coordinate: checkIn.location.toCLLLocationCoordinate2D()) {
                        PinView(label: checkIn.title ?? "f", isSelected: self.selectedCheckIn?.id == checkIn.id)
                            .onTapGesture {
                                self.selectedCheckIn = checkIn
                                self.showDetail = true
                            }
                    }
                }
                
                // Display dropped pin
                if let new = newCheckIn {
                    MapViewAnnotation(coordinate: new.location.toCLLLocationCoordinate2D()) {
                        PinView(label: new.title ?? "f", fillColour: .red)
                    }
                }
                
                // Initiate New Check-In
                LongPressInteraction { interaction in
                    self.newCheckIn = CheckIn.new(location: interaction.coordinate)
                    self.showNewCheckInView = true
                    return true
                }
                
                // Tap map, clear dropped pin and/or sheets
                TapInteraction { interaction in
                    // clear selected stuffcc
                    self.newCheckIn = nil
                    self.showDetail = false
                    self.selectedCheckIn = nil
                    self.showNewCheckInView = false
                    return true
                }
            }
            
            // Show CheckIn Detail Sheet
            .sheet(isPresented: $showDetail) {
                if let checkIn = self.selectedCheckIn {
                    CheckInView(checkIn: checkIn)
                        .presentationDetents([.fraction(0.3), .large])
                        .presentationDragIndicator(.visible)
                        .interactiveDismissDisabled(true)
                        .presentationBackgroundInteraction(.enabled)
                } else {
                    Text("Nothing!")
                }
            }
            
            // Show the Edit (Add) CheckIn sheet when a new checkin is dropped
            .sheet(isPresented: $showEditCheckIn) {
                EditCheckInView(checkIn: self.selectedCheckIn)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(true)
                    .presentationCornerRadius(20)
                    .edgesIgnoringSafeArea(.top)
                    .presentationDragIndicator(.hidden)
            }
            
            // Show the confirmation sheet when a pin is dropped
            .sheet(isPresented: $showNewCheckInView) {
                let mapTapInfo = "Check in here?"
                NewCheckInDialog(info: mapTapInfo, onCancel: { self.newCheckIn = nil }, onConfirm: { addNewCheckIn() })
                    .presentationDetents([.fraction(0.2)])
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationCornerRadius(20)
                    .edgesIgnoringSafeArea(.top)
                    .presentationDragIndicator(.hidden)
            }
            
            .ignoresSafeArea()
        }
        .onAppear {
            if let _ = selectedCheckIn {
                self.showDetail = true
            }
        }
    }

    /**
     Adds a new checkin to the array (this should only happen after a successful save)
     */
    func addNewCheckIn() {
        if let new = self.newCheckIn {
            self.checkIns.append(new)
            self.newCheckIn = nil
            self.showEditCheckIn = true
        }
    }
}

#Preview {
    @Previewable @State var checkIns = [
        CheckIn(id: "12", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: -41.29, longitude: 174.7787).toGeoPoint(), title: "Hotel High Five", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something "),
        CheckIn(id: "13", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: -41.39, longitude: 174.7887).toGeoPoint(),  title: "Camp of Dissappointment", notes: "this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes ")]
    
    MapView(checkIns: $checkIns)
}
