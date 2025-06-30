//
//  Home.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack() {
            Text("HOME")
            NavigationLink {
                HikeView()
            } label: {
                Text("SELECT HIKE")
            }
        }
    }
}

#Preview {
    HomeView()
}
