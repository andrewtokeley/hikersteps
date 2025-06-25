//
//  hikerstepsApp.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 26/06/25.
//

import SwiftUI

@main
struct hikerstepsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
