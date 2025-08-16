import SwiftUI

struct NotificationsViewTest: View {
    struct UserNotification: Identifiable, Hashable {
        let id: UUID
        let title: String
        let body: String
        let type: NotificationType
        var isRead: Bool = false
    }

    enum NotificationType: Hashable {
        case newCheckIn(hikeId: String)
        case systemMessage(String)
    }
    
    @State private var notifications: [UserNotification] = [
        .init(id: UUID(), title: "New Check-In", body: "Hike 123", type: .newCheckIn(hikeId: "123")),
        .init(id: UUID(), title: "System", body: "Update at 10pm", type: .systemMessage("Update at 10pm"))
    ]
    
    @State private var path: [UUID] = []
    
    var body: some View {
        NavigationStack(path: $path) {
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
            .navigationTitle("Notifications")
//            .navigationDestination(for: UUID.self) { id in
//                destinationView(for: notifications[1])
//                    .onDisappear() {
//                        if let index = notifications.firstIndex(where: { $0.id == id }) {
//                            self.notifications[index].isRead = true
//                        }
//                    }
//            }
        }
    }
    
    @ViewBuilder
    func destinationView(for notification: UserNotification) -> some View {
        switch notification.type {
        case .newCheckIn(let hikeId):
            Text("Check-In Detail for hike \(hikeId)")
        case .systemMessage(let message):
            Text("System Message: \(message)")
        }
    }
}

#Preview {
    NotificationsViewTest()
}
