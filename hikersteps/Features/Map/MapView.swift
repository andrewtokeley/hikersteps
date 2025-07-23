//
//  MapView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import SwiftUI
import CoreLocation
import MapboxMaps

struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    
    // State controlled (and mutated) by this view
    @StateObject private var viewModel = ViewModel()
    @State private var mapTapInfo: String? = ""
    @State private var showDetail: Bool = false
    @State private var showNewCheckInView: Bool = false
    @State private var selectedCheckIn: CheckIn?
    
    // Bound to the source of truth in the HikeView parent's viewmodel
    @Binding var checkIns: [CheckIn]
   
    var body: some View {
        ZStack {
            MapboxWrapperView(checkInAnnotations: $viewModel.checkInAnnotations, mapTapInfo: $mapTapInfo
                              , onMapTap: { _ in
                if (showDetail) {
                    // close details sheet, if present
                    showDetail = false
                } else {
                    // suggest adding a new checkin
                    showNewCheckInView = true
                }
            }
                              , onAnnotationTap: { annotation in
                DispatchQueue.main.async {
                    self.selectAnnotation(annotation)
                }
            }
            )
            .ignoresSafeArea()
        }
        .onAppear {
            viewModel.loadAnnotations(from: checkIns)
        }
        .onChange(of: checkIns) {
            viewModel.loadAnnotations(from: checkIns)
        }
        .onChange(of: viewModel.selectedAnnotation) {
            if let selected = viewModel.selectedAnnotation {
                // find the corresponding checkin
                self.selectedCheckIn = self.checkIns.first(where: { $0.id == selected.checkInId })
            }
        }
        .sheet(isPresented: $showDetail) {
            CheckInView(checkIn: $selectedCheckIn)
                .presentationDetents([.fraction(0.3), .large])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $showNewCheckInView) {
            NewCheckInDialog(info: mapTapInfo)
                .presentationDetents([.fraction(0.3)])
                .interactiveDismissDisabled(true)
                .presentationBackgroundInteraction(.enabled)
                .presentationCornerRadius(20)
                .edgesIgnoringSafeArea(.top)
                .presentationDragIndicator(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {  // 2. Custom back button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.black, .white)
                        .font(.title2)
                        
                        //.background(.gray)
                }
            }
        }
    }
    
    func selectAnnotation(_ annotation: CheckInAnnotation) {
        self.viewModel.selectAnnotation(annotation: annotation)
        showDetail = true
    }
     
}

#Preview {
    @Previewable @State var checkIns = [
        CheckIn(id: "12", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: -41.29, longitude: 174.7787).toGeoPoint(), title: "Hotel High Five", notes: "I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something I want to say something "),
        CheckIn(id: "13", uid: UUID().uuidString, locationAsGeoPoint: Coordinate(latitude: -41.39, longitude: 174.7887).toGeoPoint(),  title: "Camp of Dissappointment", notes: "this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes this is some notes ")]
    
    MapView(checkIns: $checkIns)
}

