//
//  CheckInMarker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import CoreLocation

/**
 A CheckInAnnotation contains information about where and how to display a CheckIn indicator on a map.
 
 It is defined as an ObservableObject so that changes to it's properties can be monitored by views to update accordingly
 */
struct CheckInAnnotation: Identifiable, Equatable {
    
    /**
     Guaranteed unique id for the annotation
     */
    var id: String
    
    /**
     Annotation's location on a map
     */
    var coordinate: CLLocationCoordinate2D
    
    /**
     Title that may be displayed under an annotation's view
     */
    var title: String?
    
    /**
     checkInId to link the annotation with it's underlying CheckIn
     */
    var checkInId: String?
    
    /**
     Flag to indicate whether the annotation should display in selected state.
     This property is published as it can impact the way annotations are displayed
     */
    var selected: Bool = false
    
    /**
     Flag to indicate whether the annotation should be display as if it's a new annotation, for example, a dropped pin, that's not yet a saved CheckIn
     */
    var isNew: Bool = false
    
    /**
     Construct a new CheckInAnnotation
     */
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, checkInId: String? = nil, isNew: Bool = false) {
        self.id = UUID().uuidString
        self.coordinate = coordinate
        self.title = title
        self.isNew = isNew
        self.checkInId = checkInId
    }
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, checkInId: String? = nil, isNew: Bool = false) {
        self.init(coordinate: coordinate, title: title, subtitle: subtitle, checkInId: checkInId, isNew: isNew)
        self.id = id
    }
    
    /**
     Initialise the annotation from a CheckIn
     */
    init(checkIn: CheckIn) {
        self.id = UUID().uuidString
        self.coordinate = checkIn.location.toCLLLocationCoordinate2D()
        self.title = checkIn.title
        self.checkInId = checkIn.id
        self.selected = false
        self.isNew = false
        
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
