//
//  ShareBuilder.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 27/08/2025.
//

import Foundation
import UIKit

class ShareActivities {
    
    var items: [Any]
    
    init(items: [Any]) {
        self.items = items
    }
    
    /**
     Returns a ShareActivities instance for a Journal or Journal Entry
     */
    static func createForJournal(username: String, journalId: String, checkIn: CheckIn?, shareOptions: ShareOptions) async -> ShareActivities {
        var activityItems: [Any] = []
        
        // TITLE
        if let title = checkIn?.title {
            activityItems.append(title)
        }
        
        // IMAGE
        if let imageUrl = checkIn?.images.first?.storageUrl {
            if let url = URL(string: imageUrl) {
                let request = URLRequest(url: url)
                if let result = try? await URLSession.shared.data(for: request) {
                    if let uiImage = UIImage(data: result.0) {
                        activityItems.append(uiImage)
                    }
                }
            }
        }
        
        // NOTES
        if let notes = checkIn?.notes {
            activityItems.append(notes.trimCharacters(from: 100))
        }
        
        // LINK
        let builder = ShareLinkBuilder(host: "istayedhere.com")
        if let url = builder.urlForJournal(username: username, journalId: journalId, checkInId: checkIn?.id, options: shareOptions) {
            activityItems.append(url)
        } else {
            //
        }
        
        return ShareActivities(items: activityItems)
    }
}
