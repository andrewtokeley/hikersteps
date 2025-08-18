//
//  HikeDetails.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 08/08/2025.
//

import SwiftUI

struct TestingView: View {
    
    @State private var showShare = false
    @State private var topSectionHeight: CGFloat = 200
    
    let hike: Hike
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Image("hiker-journal")
                    .resizable()
                    .scaledToFill()
                    .frame(height: topSectionHeight + topSafeAreaInset())
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                    .frame(height: topSectionHeight)
                VStack {
                    HStack {
                        Text("Last journal entry")
                        Spacer()
                        Text(Date().formatted(.dateTime.weekday().day().month().year()))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
      
    func topSafeAreaInset() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.safeAreaInsets.top ?? 0
    }
    func statusBarHeight() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = scene?.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
}

#Preview {
    TestingView(hike: Hike.sample)
}
