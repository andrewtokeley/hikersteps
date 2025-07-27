////
////  MapView-ViewModel.swift
////  hikersteps
////
////  Created by Andrew Tokeley on 04/07/2025.
////
//
//import Foundation
//import CoreLocation
//
//protocol ViewModelProtocol: ObservableObject {
//    var checkInAnnotations: [CheckInAnnotation] { get }
//    func loadAnnotations(from checkIns: [CheckIn])
//}
//
//extension MapView {
//    
//    protocol ViewModelProtocol: ObservableObject {
//        var checkIns: [CheckIn] { get set }
//        func loadHikes()
//    }
//    
//    class ViewModel: ViewModelProtocol {
//    }
//}
//        
//class ViewModel: ViewModelProtocol {
//    var checkIn: [CheckIn]
////    @Published var checkInAnnotations: [CheckInAnnotation] = []
////    @Published var selectedAnnotation: CheckInAnnotation?
//    
//    var selectedAnnotationIndex: Int? {
//        return checkInAnnotations.firstIndex(where: { $0.selected })
//    }
//    
//    /**
//     Updates the ViewModel's CheckInAnnotations array
//     */
//    func loadAnnotations(from checkIns: [CheckIn]) {
//        checkIns.forEach { checkIn in
//            // need to calculate the day number for the title here... but need to think about how it updates?
//            let newAnnotation =
//                CheckInAnnotation(
//                    coordinate: CLLocationCoordinate2D(latitude: checkIn.location.latitude, longitude: checkIn.location.longitude),
//                    title: checkIn.id,
//                    subtitle: checkIn.date.description,
//                    checkInId: checkIn.id
//                )
//            // reassigning ensures the change is Published to the View
//            self.checkInAnnotations = self.checkInAnnotations + [newAnnotation]
//        }
//    }
//    
//    func dropPin(at: CLLocationCoordinate2D) {
//        var newCheckIn = CheckIn.new(location: at)
//        newCheckIn.date = Date()
//        let newAnnotation =
//            CheckInAnnotation(
//                coordinate: at,
//                title: newCheckIn.title,
//                subtitle: "",
//                checkInId: "0",
//                isNew: true
//            )
//        self.checkInAnnotations = self.checkInAnnotations + [newAnnotation]
//    }
//    
//    func removedDroppedPin() {
//        self.checkInAnnotations.removeAll(where: { $0.isNew })
//    }
//    
//    func selectAnnotation(annotation: CheckInAnnotation) {
//        // de-select previously selected annotation
//        if let index = selectedAnnotationIndex {
//            self.checkInAnnotations[index].selected = false
//        }
//        
//        // select the new annotation
//        if let selectedAnnotation = self.checkInAnnotations.first(where: { $0.checkInId == annotation.checkInId }) {
//            
//            selectedAnnotation.selected = true
//            
//            // set the Published property to notify view
//            self.selectedAnnotation = selectedAnnotation
//        }
//    }
//    
//    
//}
//
