//
//  ShareLinkBuilder.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/08/2025.
//

import Foundation


enum ShareLocation {
    case start
    case latest
    case end
    case custom
    case checkIn
}

struct ShareOptions {
    /// Describe where to centre the viewport on when the user follows the share
    var viewportCentre: ShareLocation = .start
    
    /// Supplies the coordinates to navigate to. Must be set when viewportCentre == .custom.
    var viewportCentreCoordinate: Coordinate? = nil
    
    /// Zoom level, default is 10
    var zoomLevel: Int? = 10
    
    /// Specifies whether the link has been created from a share action. This is simply for anayltical purposes to see how widely links are being shared and distinguish from urls that are created inside the web app itself. Default is false.
    var isShare: Bool = false
}

class ShareLinkBuilder {
    
    /// Get this from info?
    var host: String = "istayedhere.com"
    
    var urlComponents: URLComponents
    
    /**
     - Parameters:
        - host: the host of the website being redirected to. For example, istatedhere.com or, in the case of development, istayedhere-dev.com
     */
    init(host: String) {
        
        self.host = host
        
        self.urlComponents = URLComponents()
        self.urlComponents.scheme = "https"
        self.urlComponents.host = self.host
    }
    
    /**
     Returns the url for the user's public home page
     */
    func urlForUserHome(username: String) -> URL? {
        urlComponents.path = "/\(username)"
        urlComponents.queryItems?.removeAll()
        return urlComponents.url
    }
    
    /**
     Returns a shareable web URL that the app can use to share a Journal or Journal Entry.
     
     - Parameters:
        - username: the username of the journal owner
        - journalId: id of the journal
        - checkInId: optional id of the journal entry
        - options: `ShareOptions` to describe additional information about how and where to configure the viewport presented to the user
     For example, https://istayedhere.com/tokes/view/xRbf9iEmF00ejJSwIm4u?goto=start&zoom=5&share=true
     */
    func urlForJournal(username: String, journalId: String, checkInId: String?, options: ShareOptions) -> URL? {
        
        urlComponents.queryItems?.removeAll()
        
        // goto latest/start
        if (options.viewportCentre == .latest) {
            urlComponents.queryItems?.append(URLQueryItem(name: "goto", value: "latest"))
        } else if (options.viewportCentre == .start) {
            urlComponents.queryItems?.append(URLQueryItem(name: "goto", value: "start"))
        }
        
        if (options.viewportCentre == .custom) {
            if let coordinate = options.viewportCentreCoordinate {
                urlComponents.queryItems?.append(URLQueryItem(name: "lat", value: String(coordinate.latitude)))
                urlComponents.queryItems?.append(URLQueryItem(name: "lng", value: String(coordinate.longitude)))
            }
        }
        
        if let zoom = options.zoomLevel {
            urlComponents.queryItems?.append(URLQueryItem(name: "zoom", value: String(zoom)))
        }
        
        if (options.isShare) {
            urlComponents.queryItems?.append(URLQueryItem(name: "share", value: String(options.isShare)))
        }
        
        // Build up the path
        urlComponents.path = "/\(username)/view/\(journalId)"
        
        if options.viewportCentre == .checkIn {
            if let checkInId = checkInId {
                urlComponents.path += "/\(checkInId)"
            } else {
                // error?
            }
        }
        
        return urlComponents.url
    }
}
