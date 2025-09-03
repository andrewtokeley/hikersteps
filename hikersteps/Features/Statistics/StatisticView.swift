//
//  StatisticView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import SwiftUI

struct StatisticView: View {

    var statistic: String // e.g. 44km
    var description: String // e.g. Longest Day
    
    var onInfoDetails: (() -> (String, String))?
    
    @State private var explainationDetails: String?
    @State private var explainationTitle: String?
    @State private var showExplaination: Bool = false
    
    
    var body: some View {
        VStack {
            VStack {
                Text(description)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 10)
                
                Text(statistic)
                    .bold()
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    VStack (spacing: 10) {
        HStack {
            Group {
                StatisticView(statistic: "44km", description: "Total Distance")
                StatisticView(statistic: "35km", description: "Total Distance")
            }
            .frame(width: 140)
            .background(.red)
        }
        
        HStack (alignment: .top) {
            Group {
                StatisticView(statistic: "21kg", description: "Base Weight")
                StatisticView(statistic: "21 days", description: "Day")
                
            }
            .frame(width: 140)
            .background(.blue)
        }
    }
    .padding()
}
