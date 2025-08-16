//
//  Statistics.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import SwiftUI

struct HikeStatisticsView: View {
    
    let hike: Hike
    
    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    HStack {
                        StatisticView(numberUnit: hike.statistics.totalDays, description: "Days")
                        Spacer()
                        StatisticView(numberUnit: hike.statistics.totalRestDays, description: "Rest Days")
                    }
                    
                    HStack {
                        StatisticView(numberUnit: hike.statistics.totalDistanceWalked, description: "Total Distance")
                        Spacer()
                        StatisticView(numberUnit: hike.statistics.longestDistance, description: "Longest Day")
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        
    }
}

struct PreviewWrapper2: View {
    
    @State var hike = Hike()
    @State var show: Bool = false
    
    var body: some View {
        VStack {
            if show {
                HikeStatisticsView(hike: hike)
            }
            Spacer()
        }
        .onAppear {
            self.hike = Hike.sample
            self.show = true
        }
    }
}
#Preview {
    PreviewWrapper2()
}
