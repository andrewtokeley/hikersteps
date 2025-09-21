//
//  TileView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 18/09/2025.
//

import SwiftUI
import NukeUI

struct TileView: View {
    var imageUrlString: String
    var title: String
    var body: some View {
        ZStack {
            LazyImage(source: imageUrlString) { state in
                if let image = state.image {
                    image
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.9), Color.clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 40)
                    }
                    VStack {
                        Spacer()
                        Text(title).bold()
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.bottom, 10)
                    }
                } else if state.error != nil {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                    VStack {
                        Spacer()
                        Text(title)
                            .font(.caption)
                            .padding(.bottom, 10)
                    }
                } else {
                    ProgressView()
                        .tint(.accentColor)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .background(Color(.gray).opacity(0.15))
            .border(Color(.appLightGray))
        }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 3)],
                  spacing: 3) {
            TileView(imageUrlString: CheckIn.sample().image.storageUrl, title: "Day 1")
            TileView(imageUrlString: CheckIn.sample().image.storageUrl, title: "Day 2")
            TileView(imageUrlString: CheckIn.sample().image.storageUrl, title: "Day 3")
            TileView(imageUrlString: CheckIn.sample().image.storageUrl, title: "Day 4-5")
            
        }
    }.padding()
}
