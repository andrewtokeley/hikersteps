//
//  Statistics.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import SwiftUI

struct JournalStatisticsView: View {
    
    let hike: Journal
    
    var body: some View {
        NavigationStack {
            VStack {
                Group {
                    HStack {
                        StatisticView(statistic: "\(hike.statistics.totalDays) days", description: "Days")
                        Spacer()
                        StatisticView(statistic: "\(hike.statistics.totalRestDays) days", description: "Rest Days")
                    }
                    
                    HStack {
                        StatisticView(statistic: hike.statistics.totalDistanceWalked.formatted(), description: "Total Distance")
                        Spacer()
                        StatisticView(statistic: hike.statistics.longestDistance.formatted(), description: "Longest Day")
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
    
    @State var hike: Journal = Journal.nilValue
    @State var show: Bool = false
    
    var body: some View {
        VStack {
            if show {
                JournalStatisticsView(hike: hike)
            }
            Spacer()
        }
        .onAppear {
            self.hike = Journal.sample
            self.show = true
        }
    }
}
#Preview {
    PreviewWrapper2()
}
