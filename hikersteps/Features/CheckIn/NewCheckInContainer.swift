//
//  NewCheckInContainer.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 19/08/2025.
//

import SwiftUI

struct NewCheckInContainer: View {
    @State private var sheetHeight: CGFloat = 0
    @State private var containerHeight: CGFloat = 0
    
    // Change these if you use custom detents
    private let mediumHeight: CGFloat = 300
    private let largeHeight: CGFloat = 600
    
    var body: some View {
        GeometryReader { proxy in
            let currentHeight = proxy.size.height
            let progress = min(max((currentHeight - mediumHeight) / (largeHeight - mediumHeight), 0), 1)
            
            ZStack {
                CompactView()
                    .opacity(1 - progress)
                
                ExpandedView()
                    .opacity(progress)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.none, value: progress) // disable snap animation
        }
    }
}

struct CompactView: View {
    var body: some View {
        VStack {
            Text("Title")
            Text("the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon ")
            Spacer()
        }
    }
}

struct ExpandedView: View {
    var body: some View {
        VStack {
            Text("Title")
            Text("the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon the quick brown fox jumped over the moon ")
            Text("Something Else")
            Text("some other information other information other information other information ")
            Spacer()
        }
    }
}
