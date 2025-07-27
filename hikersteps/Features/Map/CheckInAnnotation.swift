//
//  CheckInMarker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import MapKit

class CheckInAnnotation: NSObject, MKAnnotation {
    /**
     Annotation's location on a map
     */
    var coordinate: CLLocationCoordinate2D
    
    /**
     Title that may be displayed under an annotation's view
     */
    var title: String?
    
    /**
     Tag that can be used to link the annotation to another entity, for example, a CheckIn.id
     */
    var tag: String?
    
    /**
     Flag to indicate whether the annotation should display in selected state
     */
    var selected: Bool = false
    
    /**
     Flag to indicate whether the annotation should be display as if it's a new annotation, for example, a dropped pin, that's not yet a saved CheckIn
     */
    var isNew: Bool = false
    
    /**
     Construct a new CheckInAnnotation
     */
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, tag: String? = nil, isNew: Bool = false) {
        self.coordinate = coordinate
        self.title = title
        self.tag = tag
        self.isNew = isNew
    }
}
