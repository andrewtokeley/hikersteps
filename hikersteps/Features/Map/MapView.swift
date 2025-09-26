//
//  MapNew.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 24/07/2025.
//

import SwiftUI
import MapboxMaps

/**
 The MapView represents the map, annotations and interactions of your journal
 */
struct MapView: View {
    
    /// Annotations for each saved checkin
    @Binding var annotations: [CheckInAnnotation]
    
    /// Annotation that should be rendered as selected
    @Binding var selectedAnnotationIndex: Int
    
    @State private var viewport: Viewport =  Viewport.camera(center: Coordinate.wellington.clLocationCoordinate2D, zoom: 10, bearing: 0, pitch: 0)
    
    // Toggle to determine whether a change in selected annotation is a result of a user tap or from the selectedAnnotationIndex binding changing.
    @State private var isTapNavigation: Bool
    
    // Annotation that describes where to render a dropped pin
    @Binding var droppedPinAnnotation: CheckInAnnotation?
    
    //var annotationSafeArea: CGRect
    @Binding var bottomPadding: CGFloat
    
    // Private event handlers
    private var onDidSelectAnnotation: ((CheckInAnnotation) -> Void)?
    private var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    private var onMapLongPress: ((CLLocationCoordinate2D) -> Void)?
    private var onPuckTap: ((CLLocationCoordinate2D) -> Void)?
    /**
     Default constructor
     */
    init(annotations: Binding<[CheckInAnnotation]>, selectedAnnotationIndex: Binding<Int> = .constant(-1), bottomPadding: Binding<CGFloat> = .constant(0), droppedPinAnnotation: Binding<CheckInAnnotation?> = .constant(nil) ) {
        
        _annotations = annotations
        _selectedAnnotationIndex = selectedAnnotationIndex
        _droppedPinAnnotation = droppedPinAnnotation
        
        _isTapNavigation = State(initialValue: false)
        _bottomPadding = bottomPadding
        //self.annotationSafeArea = annotationSafeArea
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
                Puck2D(bearing: .heading)
                
                // Display checkins
                ForEvery(Array(annotations.enumerated()), id: \.element.id) { index, annotation in
                    MapViewAnnotation(coordinate: annotation.coordinate.clLocationCoordinate2D) {
                        PinView(label: annotation.title ?? "", state: pinState(annotation, index), showLabel: false)
                            .onTapGesture {
                                
                                // if we've tapped on a new annotation, mark this as a tapNavigation, otherwise clear the flag so that when we programmatically navigate away from the re-selected annotation, we follow it!
                                if (selectedAnnotationIndex != index) {
                                    isTapNavigation = true
                                } else {
                                    isTapNavigation = false
                                }
                                
                                ensureAnnotationVisible(proxy, annotation.coordinate)
                                
                                selectedAnnotationIndex = (selectedAnnotationIndex == index) ? -1 : index
                                
                                onDidSelectAnnotation?(annotation)
                            }
                    }
                }
                // Display dropped pin
                if let drop = droppedPinAnnotation {
                    MapViewAnnotation(coordinate: drop.coordinate.clLocationCoordinate2D) {
                        PinView(label: drop.title ?? "f", state: .dropped)
                    }
                }
                
                LongPressInteraction { interaction in
                    ensureAnnotationVisible(proxy, interaction.coordinate.coordinate)
                    onMapLongPress?(interaction.coordinate)
                    return true
                }
                
                TapInteraction { interaction in
                    onMapTap?(interaction.coordinate)
                    return true
                }
            }
            .ornamentOptions(
                OrnamentOptions(
                    logo:LogoViewOptions(
                        position: .bottomLeading,
                        margins: CGPoint(x:10, y: bottomPadding + 10 )
                    ),
                    attributionButton: AttributionButtonOptions(
                        position: .bottomTrailing,
                        margins: CGPoint(x:10, y: bottomPadding + 10)
                    )
                )
            )
            .animation(.easeInOut(duration: 0.5), value: bottomPadding)
            
            .onChange(of: bottomPadding) { old, new in
                if old != new {
                    // recentre the selected annotation
                    if selectedAnnotationIndex >= 0 {
                        let coordinate = annotations[selectedAnnotationIndex].coordinate
                        ensureAnnotationVisible(proxy, coordinate)
                    } else {
                        // just update the viewport to reflect the new padding
                        let cameraOptions = CameraOptions(padding: UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0))
                        proxy.camera?.ease(to: cameraOptions, duration: 0.1)
                    }
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                LocateMeButton(viewport: $viewport)
                    .padding(.top, 140)
                    .padding(.trailing)
            }
            .onChange(of: self.selectedAnnotationIndex, { oldValue, newValue in
                guard !self.annotations.isEmpty else { return }
                
                // unless the user has tapped on an annotation make sure the selected annotation is visible.
                if !isTapNavigation && newValue >= 0 {
                    
                    let annotation = self.annotations[newValue]
                    animateToCoordinate(proxy, annotation.coordinate)
                }
                isTapNavigation = false
            })
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
    
    func onPuckTap(_ handler: @escaping (CLLocationCoordinate2D) -> Void) -> MapView {
        var copy = self
        copy.onPuckTap = handler
        return copy
    }
    
    /**
     If tapping the annotation results in it being below the bottomPadding then re-centre
     */
    func ensureAnnotationVisible(_ proxy: MapProxy, _ coordinate: Coordinate) {
        if let map = proxy.map {
            let point = map.point(for: coordinate.clLocationCoordinate2D)
            if point.y < bottomPadding {
                animateToCoordinate(proxy, coordinate)
            }
        }
    }
    
    /**
     Animates the viewport to centre on the annotation, with a given offset
     */
    func animateToCoordinate(_ proxy: MapProxy, _ coordinate: Coordinate) {
        
        let centre = coordinate.clLocationCoordinate2D
        
        let cameraOptions = CameraOptions(center: centre, padding: UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0))
        proxy.camera?.ease(to: cameraOptions, duration: 0.1)        
    }
    
    
}

#Preview {
    @Previewable @State var annotations = [
        CheckInAnnotation(id: "1", coordinate: Coordinate(latitude: -41.29, longitude: 174.7787), title: "Hotel High Five"),
        CheckInAnnotation(id: "22", coordinate: Coordinate(latitude: -41.39, longitude: 174.7787), title: "Camp of Dissappointment")
        ]
    @Previewable @State var selectedIndex: Int = 1
    
    MapView(annotations: $annotations, selectedAnnotationIndex: $selectedIndex )
        .onPuckTap({ location in
            print("puck tapped at \(location)")
        })
        .onMapTap({ location in
            print("map tapped at \(location)")
        })
        .ignoresSafeArea()
        
}
