//
//  HikeCard.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 30/07/2025.
//

import SwiftUI

struct HikeCard: View {
    var hike: Hike
    
    var body: some View {
        HStack {
            if let url = URL(string: hike.heroImageUrl) {
                Group {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fill)
                    } placeholder: {
                        Text("...")
                            .foregroundStyle(Color(.appLightGray))
                    }
                }
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.appLightGray), lineWidth: 1)
                )
            } else {
                Image("pct")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .clipped()
            }
            
            VStack(alignment: .leading) {
                Text(hike.name)
                    .foregroundStyle(.primary)
                    .font(.headline)
                Text(hike.startDate.formatted(.dateTime.day().month().year()))
                    .foregroundStyle(.primary)
                Group {
                    Text("Completed")
                    HStack {
                        Text(hike.statistics.totalDistanceWalked.description)
                        Text(" in ")
                        Text(hike.statistics.totalDays.description)
                    }
                }
                .foregroundStyle(.secondary)
                Spacer()
            }
            Spacer()
        }
        .frame(height: 110)
        .padding(.bottom)
        
    }
}


#Preview {
    @Previewable @State var hike = Hike(name: "TA 2021/22", description: "This is a test hike", startDate: Date())
    HikeCard(hike: hike)
}
