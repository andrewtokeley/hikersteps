////
////  HikeMapView.swift
////  hikersteps
////
////  Created by Andrew Tokeley on 02/07/2025.
////
//
//import SwiftUI
//import MapboxMaps
//
//struct MapboxWrapperView: UIViewRepresentable {
//    @Binding var checkInAnnotations: [CheckInAnnotation]
////    @Binding var selectedAnnotation: CheckInAnnotation?
//    @Binding var mapTapInfo: String?
//    
//    /**
//     The assigned closure will be called when the map is tapped. Note it won't be called when an annotation is tapped.
//     */
//    var onMapTap: ((CLLocationCoordinate2D) -> Void)?
//    
//    var onMapLongPress: ((CLLocationCoordinate2D) -> Void)?
//    
//    var onAnnotationTap: ((CheckInAnnotation) -> Void)?
//    
//    var onDragAnnotation: (() -> Void )?
//    
//    /**
//     This method is automatically called by the SwiftUI framework when the view is first created (or needs to be recreated).
//     */
//    func makeUIView(context: Context) -> MapboxMaps.MapView {
//        let mapInitOptions = MapInitOptions(
//            styleURI: StyleURI(rawValue: "mapbox://styles/andrewtokeley/cmczljbid00fs01r43add8d2m")
//        )
//        let mapView = MapboxMaps.MapView(frame: .zero, mapInitOptions: mapInitOptions)
//        
//        //let _ = mapView.mapboxMap.onMapLoaded.observeNext { _ in
//            
//            // Attempt to modify the "water" layer color
////            do {
////                try mapView.mapboxMap.setLayerProperty(
////                    for: "mile-markers",
////                    property: "fill-color",
////                    value: "#45d9ca"
////                )
////                print("worked!")
////            } catch {
////                print("Failed to set layer property: (error)")
////            }
//        //}
//        
//        // Attach the map tap listener and delegate to the Coordinator to handle
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
//        tapGesture.delegate = context.coordinator
//        mapView.addGestureRecognizer(tapGesture)
//        
//        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
//        tapGesture.delegate = context.coordinator
//        mapView.addGestureRecognizer(longPressGesture)
//        
//        // Give the Coordinator an opportunity to configure itself for the mapView - for example, creating an annotation manager
//        context.coordinator.prepareForMapView(mapView)
//        return mapView
//    }
//    
//    /**
//     This method is automatically called by the SwiftUI framework whenever dependencies on the view occur. For example, if the bindings change.
//     */
//    func updateUIView(_ uiView: MapboxMaps.MapView, context: Context) {
//        context.coordinator.updateAnnotations(mapView: uiView, checkInAnnotations: checkInAnnotations)
//    }
//    
//    /**
//     Associate the Coordinator with this struct
//     */
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    /**
//     The Coordinator is the primary way for this view to communicate with the SwiftUI view.
//     */
//    class Coordinator: NSObject, UIGestureRecognizerDelegate {
//        var parent: MapboxWrapperView
//        private var circleManager: CircleAnnotationManager?
//        private var firstLoad = true
//        private var cancellable: Cancelable?
//        
//        init(_ parent: MapboxWrapperView) {
//            self.parent = parent
//        }
//        
//        func prepareForMapView(_ mapView: MapboxMaps.MapView) {
//            circleManager = mapView.annotations.makeCircleAnnotationManager()
//        }
//        
//        /**
//         Handle Map Tap and call the onMapTap closure defined by the hosting SwiftUI View (MapView)
//         */
//        @objc func handleLongPress(_ gestureRecognizer: UITapGestureRecognizer) {
//            
//            let mapView = gestureRecognizer.view as! MapboxMaps.MapView
//            let location = gestureRecognizer.location(in: mapView)
//            let coordinate = mapView.mapboxMap.coordinate(for: location)
//
//            self.getMoreInfo(mapView: mapView, screenPoint: location) { description in
//                self.parent.mapTapInfo = description
//            }
//            parent.onMapLongPress?(coordinate)
//        }
//        
//        /**
//         Handle Map Tap and call the onMapTap closure defined by the hosting SwiftUI View (MapView)
//         */
//        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
//            
//            let mapView = gestureRecognizer.view as! MapboxMaps.MapView
//            let location = gestureRecognizer.location(in: mapView)
//            let coordinate = mapView.mapboxMap.coordinate(for: location)
//            
//            // if the tap was on an annotation we don't want to raise the map tap
//            if let circleManager = circleManager {
//                if circleManager.annotations.count > 0 {
//                    if let radius = circleManager.annotations[0].circleRadius {
//                        let size = CGSize(width: radius*2, height: radius*2)
//                        let annotation = circleManager.annotations.first { annotation in
//                            guard case let .point(point) = annotation.geometry else { return false }
//                            let rect = CGRect(origin: mapView.mapboxMap.point(for: point.coordinates), size: size)
//                            return rect.offsetBy(dx: -radius, dy: -radius).contains(location)
//                        }
//                        
//                        if let _ = annotation {
//                            return
//                        }
//                    }
//                }
//            }
//            
//            self.getMoreInfo(mapView: mapView, screenPoint: location) { description in
//                self.parent.mapTapInfo = description
//            }
//            parent.onMapTap?(coordinate)
//        }
//        
//        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//            true
//        }
//        
//        /**
//         Create/remove annotations for each CheckInAnnotation bound to the parent
//         */
//        func updateAnnotations(mapView: MapboxMaps.MapView, checkInAnnotations: [CheckInAnnotation]) {
//            
//            var annotations: [CircleAnnotation] = []
//            for checkInAnnotation in checkInAnnotations {
//                let id = checkInAnnotation.checkInId!
//                var circle = CircleAnnotation(id: id, centerCoordinate: checkInAnnotation.coordinate)
//                circle.circleColor = checkInAnnotation.isNew ? StyleColor(.red) : ( checkInAnnotation.selected ? StyleColor(.orange) : StyleColor(.systemBlue))
//                circle.circleRadius = 10
//                circle.isDraggable = checkInAnnotation.isNew ? true : false
//                circle.tapHandler = { _ in
//                    
//                    // if there's a handler let it know
//                    self.parent.onAnnotationTap?(checkInAnnotation)
//                    
//                    // if this annotation would appear under the detail sheet, change the viewport to centre it
//                    let point = mapView.mapboxMap.point(for: checkInAnnotation.coordinate)
//                    if point.y > mapView.frame.height * (2/3) {
//                        self.centreAnnotation(mapView: mapView, annotation: circle)
//                    }
//                    
//                    return true
//                }
//                annotations.append(circle)
//            }
//            
//            // add (and remove) current annotations
//            circleManager?.annotations = annotations
//            
//            // when we load a new hike we're going to zoom in to the first checkin
//            if (firstLoad && annotations.count > 0) {
//                firstLoad = false
//                
//                centreAnnotation(mapView: mapView, annotation: annotations[0], initialLoad: true)
//                
//                // simulate selecting the first annotation
//                if checkInAnnotations.count > 0 {
//                    self.parent.onAnnotationTap?(checkInAnnotations[0])
//                }
//            }
//        }
//            
//        func getMoreInfo(mapView: MapboxMaps.MapView, screenPoint: CGPoint, _ completion: ((String) -> Void)?) {
//            mapView.mapboxMap.queryRenderedFeatures(with: screenPoint, options: RenderedQueryOptions(
//                layerIds: ["waypoints-1", "waypoints-10", "waypoints-100", "poi-label"],
//                filter: nil
//            )) { result in
//                switch result {
//                case .success(let features):
//                    var featuresDescription = ""
//                    
//                    // only look at the first feature
//                    if let queriedFeature = features.first?.queriedFeature {
//                        let layerId = queriedFeature.sourceLayer ?? "missing"
//                        if let name = queriedFeature.feature.properties?["name"]??.rawValue as? String {
//                            var label = ""
//                            if layerId.starts(with: "waypoint") {
//                                label = "km"
//                            }
//                            featuresDescription = "\(label) \(name)"
//                        }
//                    }
//                    completion?(featuresDescription)
//                case .failure(let error):
//                    completion?("")
//                }
//            }
//        }
//        func centreAnnotation(mapView: MapboxMaps.MapView, annotation: CircleAnnotation, initialLoad: Bool = false) {
//            guard circleManager != nil  else { return }
//            
//            if case let .point(point) = annotation.geometry {
//                let coordinate = point.coordinates
//                let cameraOptions: CameraOptions
//                if initialLoad {
//                    cameraOptions = CameraOptions(
//                        center: coordinate,
//                        zoom: 7,
//                        bearing: nil,
//                        pitch: nil
//                    )
//                    mapView.camera.ease(
//                        to: cameraOptions,
//                        duration: 1.5, // seconds
//                        completion: nil
//                    )
//                } else {
//                    cameraOptions = CameraOptions(
//                        center: coordinate,
//                        bearing: nil,
//                        pitch: nil
//                    )
//                    mapView.camera.ease(
//                        to: cameraOptions,
//                        duration: 0, // seconds
//                        completion: nil
//                    )
//                }
//                
//            }
//        }
//    }
//}
