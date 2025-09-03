//
//  MainView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/08/2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var auth: AuthenticationManager
    @State private var selectedTab = 1
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Journal", systemImage: "house")
                }.tag(1)
            Text("Follow")
                .tabItem {
                    Label("Follow", systemImage: "person.3")
                }.tag(0)
            
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthenticationManager.forPreview())
}
