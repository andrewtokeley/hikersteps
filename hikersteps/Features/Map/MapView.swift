//
//  MapNew.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 24/07/2025.
//

import SwiftUI
import MapboxMaps

struct MapView: View {
    
    /// Annotations for each saved checkin
    @Binding var annotations: [CheckInAnnotation]
    
    /// Annotation that should be rendered as selected
    @Binding var selectedAnnotationIndex: Int
    
    @State private var viewport = Viewport.camera(center: .init(latitude: Coordinate.wellington.latitude, longitude: Coordinate.wellington.longitude), zoom: 10, bearing: 0, pitch: 0)
    
    @State private var isTapNavigation: Bool
    
    // Annotation that should be rendered as a dropped-pin
    @Binding var droppedPinAnnotation: CheckInAnnotation?
    
    var annotationSafeArea: CGRect
    
    // Private event handlers
    private var onDidSelectAnnotation: ((CheckInAnnotation) -> Void)?
    private var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    private var onMapLongPress: ((CLLocationCoordinate2D) -> Void)?
        
    /**
     Default constructor
     */
    init(annotations: Binding<[CheckInAnnotation]>, selectedAnnotationIndex: Binding<Int> = .constant(-1), annotationSafeArea: CGRect = CGRect.zero, droppedPinAnnotation: Binding<CheckInAnnotation?> = .constant(nil) ) {
        
        _annotations = annotations
        _selectedAnnotationIndex = selectedAnnotationIndex
        _droppedPinAnnotation = droppedPinAnnotation
        _isTapNavigation = State(initialValue: false)
        
        self.annotationSafeArea = annotationSafeArea
    }
    
    var body: some View {
            MapReader { proxy in
                Map(viewport: $viewport) {
                     
                    // Display checkins
                    ForEvery(Array(annotations.enumerated()), id: \.element.id) { index, annotation in
                        MapViewAnnotation(coordinate: annotation.coordinate) {
                            PinView(label: annotation.title ?? "", isSelected: index == selectedAnnotationIndex)
                                .onTapGesture {
                                    isTapNavigation = true
                                    if let map = proxy.map {
                                        print("on tap annotation index")
                                        ensureAnnotationVisible(map: map, annotation: annotation)
                                    }
                                    selectedAnnotationIndex = (selectedAnnotationIndex == index) ? -1 : index
                                    onDidSelectAnnotation?(annotation)
                                }
                        }
                    }
                    
                    // Display dropped pin
                    if let drop = droppedPinAnnotation {
                        MapViewAnnotation(coordinate: drop.coordinate) {
                            PinView(label: drop.title ?? "f", fillColour: .red)
                        }
                    }
                    
                    // Initiate New Check-In
                    LongPressInteraction { interaction in
                        onMapLongPress?(interaction.coordinate)
                        return true
                    }
                    
                    // Tap map, clear dropped pin and/or sheets
                    TapInteraction { interaction in
                        onMapTap?(interaction.coordinate)
                        return true
                    }
                }
                .onChange(of: self.selectedAnnotationIndex, { oldValue, newValue in
                    guard !self.annotations.isEmpty else { return }
                    if !isTapNavigation {
                        print("centre on navigate")
                        let annotation = self.annotations[newValue]
                        animateToAnnotation(annotation)
                    }
                    isTapNavigation = false
                })
                .onChange(of: self.annotations) { oldValue, newValue in
                    if let first = self.annotations.first {
                        animateToAnnotation(first)
                        onDidSelectAnnotation?(first)
                    }
                }
                
                //
                //            // Show the Edit (Add) CheckIn sheet when a new checkin is dropped
                //            .sheet(isPresented: $showEditCheckIn) {
                //                EditCheckInView(checkIn: self.selectedCheckIn)
                //                    .presentationDetents([.large])
                //                    .interactiveDismissDisabled(true)
                //                    .presentationCornerRadius(20)
                //                    .edgesIgnoringSafeArea(.top)
                //                    .presentationDragIndicator(.hidden)
                //            }
                //
                //            // Show the confirmation sheet when a pin is dropped
                //            .sheet(isPresented: $showNewCheckInView) {
                //                let mapTapInfo = "Check in here?"
                //                NewCheckInDialog(info: mapTapInfo, onCancel: { self.newCheckIn = nil }, onConfirm: { addNewCheckIn() })
                //                    .presentationDetents([.fraction(0.2)])
                //                    .interactiveDismissDisabled(true)
                //                    .presentationBackgroundInteraction(.enabled)
                //                    .presentationCornerRadius(20)
                //                    .edgesIgnoringSafeArea(.top)
                //                    .presentationDragIndicator(.hidden)
                //            }
                
                //            .ignoresSafeArea()
                
            
        }
    }
    
    /**
     Animates the viewport to centre on the annotation
     */
    func animateToAnnotation(_ annotation: CheckInAnnotation) {
        withViewportAnimation(.easeInOut(duration: 0.3)) {
            viewport = .camera(center: annotation.coordinate)
        }
    }
    
    func onDidSelectAnnotation(_ handler: @escaping (CheckInAnnotation) -> Void) -> MapView {
        var copy = self
        copy.onDidSelectAnnotation = handler
        return copy
    }
    
    func onMapLongPress(_ handler: @escaping (CLLocationCoordinate2D) -> Void) -> MapView {
        var copy = self
        copy.onMapLongPress = handler
        return copy
    }
    
    func onMapTap(_ handler: @escaping (CLLocationCoordinate2D) -> Void) -> MapView {
        var copy = self
        copy.onMapTap = handler
        return copy
    }
    
    func ensureAnnotationVisible(map: MapboxMap, annotation: CheckInAnnotation) {
        let point = map.point(for: annotation.coordinate)
        if !annotationSafeArea.contains(point) {
            animateToAnnotation(annotation)
        }
    }
}

#Preview {
    @Previewable @State var annotations = [
        CheckInAnnotation(id: "1", coordinate: CLLocationCoordinate2D(latitude: -41.29, longitude: 174.7787), title: "Hotel High Five"),
        CheckInAnnotation(id: "2", coordinate: CLLocationCoordinate2D(latitude: -41.39, longitude: 174.7787), title: "Camp of Dissappointment")
        ]
    @Previewable @State var selectedIndex: Int = 1
    
    MapView(annotations: $annotations, selectedAnnotationIndex: $selectedIndex )
        .ignoresSafeArea()
}
