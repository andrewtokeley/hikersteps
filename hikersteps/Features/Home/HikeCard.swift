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
        VStack (alignment: .leading) {
            ZStack {
                Image("pct")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            Text(hike.name)
                .foregroundStyle(.primary)
                .font(.headline)
            Text(hike.startDate.formatted(.dateTime.weekday().day().month().year()))
                .foregroundStyle(.primary)
            HStack {
                Text("Completed")
                Text(hike.statistics.totalDistanceWalked.description)
                Text(" in ")
                Text(hike.statistics.totalDays.description)
                Spacer()
            }
            .foregroundStyle(.secondary)
        }
        .padding(.bottom)
    }
}


#Preview {
    @Previewable @State var hike = Hike(name: "TA 2021/22", description: "This is a test hike", startDate: Date())
    HikeCard(hike: hike)
}
