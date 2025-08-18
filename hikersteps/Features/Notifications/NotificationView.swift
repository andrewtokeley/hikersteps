//
//  NotificationView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 07/08/2025.
//

import SwiftUI

struct NotificationView: View {
    @State private var notifications: [Notification] = [
        Notification(id: "111", title: "System message", body: "You have a new message.", isRead: false, type: .systemMessage("Hello there")),
        Notification(id: "222", title: "New check in!", body: "Jane sent you a friend request.", isRead: false, type: .newCheckIn(hikeId: "123"))
    ]
    
    @State var selectedNotification: Notification?
    
    var body: some View {
        NavigationStack {
            VStack {
                if notifications.isEmpty {
                    Text("No notifications")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(notifications) { notification in
                        NavigationLink {
                            destinationView(for: notification)
                                .onDisappear() {
                                    if let index = notifications.firstIndex( where: { $0.id == notification.id} ) {
                                        notifications[index].isRead = true
                                    }
                                }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(notification.title).bold()
                                    Text(notification.body).font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()
                                if !notification.isRead {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    
                    Button("Mark All as Read") {
                        notifications = notifications.map {
                            Notification(title: $0.title, body: $0.body, isRead: true, type: $0.type)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    @ViewBuilder
    func destinationView(for notification: Notification) -> some View {
        switch notification.type {
        case .systemMessage(let message):
            MessageView(message: message)
        case .newCheckIn(_):
            HikeView(hike: Hike.sample)
        }
    }
}
#Preview {
    NotificationView()
}
