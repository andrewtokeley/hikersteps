//
//  Notification.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 07/08/2025.
//

import Foundation
import FirebaseFirestore

enum NotificationType: Equatable, Hashable {
    case newCheckIn(hikeId: String)
    case systemMessage(_ message: String)
}

struct Notification: Identifiable, Hashable {
    var id: String? = nil
    var title: String = ""
    var body: String = ""
    var date: Date = Date()
    var isRead: Bool = false
    var type: NotificationType = .systemMessage("Blank message")
}
