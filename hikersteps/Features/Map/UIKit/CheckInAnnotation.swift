//
//  CheckInMarker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import MapKit

class CheckInAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var checkInId: String?
    var selected: Bool = false
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, checkInId: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.checkInId = checkInId
    }
}
