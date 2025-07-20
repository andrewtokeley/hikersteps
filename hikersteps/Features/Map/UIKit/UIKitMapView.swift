//
//  HikeMapView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import SwiftUI
import MapKit

struct UIKitMapView: UIViewRepresentable {
    @Binding var checkInAnnotations: [CheckInAnnotation]
    
    var onAnnotationTap: ((CheckInAnnotation) -> Void)?
    var onMapTap: ((CLLocationCoordinate2D) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView: MKMapView = MKMapView()
        
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("UIKitMapView.updateUIView: with \(checkInAnnotations.count) checkInAnnotations")
        // Remove annotations no longer in the array
        let currentAnnotations = Set(uiView.annotations.compactMap { $0 as? CheckInAnnotation })
        let newAnnotations = Set(checkInAnnotations)
        
        let toRemove = currentAnnotations.subtracting(newAnnotations)
        let toAdd = newAnnotations.subtracting(currentAnnotations)
        
        uiView.removeAnnotations(Array(toRemove))
        uiView.addAnnotations(Array(toAdd))
        
        if toAdd.count > 0 {
            uiView.fitAll()
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: UIKitMapView
        
        init(_ parent: UIKitMapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            // Notify SwiftUI
            parent.onMapTap?(coordinate)
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            if let annotation = annotation as? CheckInAnnotation {
                parent.onAnnotationTap?(annotation)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "CheckInAnnotationView"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CheckInAnnotationView
            
            if view == nil {
                view = CheckInAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                view?.annotation = annotation
            }
            
            return view
        }
    }
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width:0.01, height:0.01)
            zoomRect            = zoomRect.union(pointRect)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
        
        for annotation in annotations {
            let aPoint          = MKMapPoint(annotation.coordinate)
            let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
            
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
}
