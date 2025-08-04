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

    private func pinState(_ annotation: CheckInAnnotation, _ index: Int) -> PinViewState {
        
        if index == selectedAnnotationIndex {
            return .selected
        } else if index == 0 {
            return .start
        } else if annotation.isNew {
            return .dropped
        } else if index == annotations.count - 1 {
            return .end
        }
        return .normal
    }
    
    var body: some View {
        MapReader { proxy in
                Map(viewport: $viewport) {
                     
                    // Display checkins
                    ForEvery(Array(annotations.enumerated()), id: \.element.id) { index, annotation in
                        MapViewAnnotation(coordinate: annotation.coordinate) {
                            PinView(label: annotation.title ?? "", state: pinState(annotation, index), showLabel: false)
                                .onTapGesture {
                                    isTapNavigation = true
                                    
                                    ensureAnnotationVisible(proxy: proxy, annotation: annotation)
                                
                                    selectedAnnotationIndex = (selectedAnnotationIndex == index) ? -1 : index
                                    
                                    onDidSelectAnnotation?(annotation)
                                }
                        }
                    }
                    // Display dropped pin
                    if let drop = droppedPinAnnotation {
                        MapViewAnnotation(coordinate: drop.coordinate) {
                            PinView(label: drop.title ?? "f", state: .dropped)
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
                .ignoresSafeArea()
                .onChange(of: self.selectedAnnotationIndex, { oldValue, newValue in
                    guard !self.annotations.isEmpty else { return }
                    if !isTapNavigation && newValue >= 0 {
                        
                        let annotation = self.annotations[newValue]
                        
                        animateToAnnotation(proxy, annotation)
                        
                        
                    }
                    isTapNavigation = false
                })
                .onChange(of: self.annotations) { oldValue, newValue in
                    if let first = self.annotations.first {
                        animateToAnnotation(proxy, first)
                        onDidSelectAnnotation?(first)
                    }
                }
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
    
    /**
     Positions the annotation in the centre of the top half of the view, away from any sheets that might be there.
     */
    func ensureAnnotationVisible(proxy: MapProxy, annotation: CheckInAnnotation) {
        if let map = proxy.map {
            let point = map.point(for: annotation.coordinate)
            if !annotationSafeArea.contains(point) {
                animateToAnnotation(proxy, annotation)
            }
        }
    }
    
    /**
     Animates the viewport to centre on the annotation
     */
    func animateToAnnotation(_ proxy: MapProxy, _ annotation: CheckInAnnotation) {
        
        if let map = proxy.map {
            let cameraOptions = CameraOptions(
                center: annotation.coordinate,
            )
            proxy.camera?.ease(to: cameraOptions, duration: 0.3)
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
