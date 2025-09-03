//
//  LocateMeButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/08/2025.
//

import SwiftUI
import MapboxMaps

struct LocateMeButton: View {
    @Binding var viewport: Viewport
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Button {
            withViewportAnimation(.default(maxDuration: 1)) {
                if let coordinate = locationManager.coordinate {
                    viewport = Viewport.camera(center: coordinate, zoom: 16.5)
                    viewport = viewport.padding(.bottom, 300)
                }
//                if isFocusingUser {
//                    viewport = .followPuck(zoom: 16.5, bearing: .heading, pitch: 60)
//                } else if isFollowingUser {
//                    viewport = .idle
//                } else {
//                    viewport = .followPuck(zoom: 13, bearing: .constant(0))
//                }
            }
        } label: {
            AppCircleButton(imageSystemName: imageName)
                .style(.filledOnImage)
                .transition(.scale.animation(.easeOut))
//            Image(systemName: imageName)
//                .transition(.scale.animation(.easeOut))
        }
        .safeContentTransition()
    }
    
    private var isFocusingUser: Bool {
        return viewport.followPuck?.bearing == .constant(0)
    }
    
    private var isFollowingUser: Bool {
        return viewport.followPuck?.bearing == .heading
    }
    
    private var imageName: String {
        if isFocusingUser {
            return  "location.fill"
        } else if isFollowingUser {
            return "location.north.line.fill"
        }
        return "location"
        
    }
}

private extension View {
    func safeContentTransition() -> some View {
        if #available(iOS 17, *) {
            return self.contentTransition(.symbolEffect(.replace))
        }
        return self
    }
}
