//
//  StatisticView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import SwiftUI

struct StatisticView: View {
    var numberUnit: any NumberUnitProtocol
    var description: String
    
    var onInfoDetails: (() -> (String, String))?
    
    @State private var explainationDetails: String?
    @State private var explainationTitle: String?
    @State private var showExplaination: Bool = false
    
    var body: some View {
        VStack {
            VStack (alignment: .trailing){
                Text(description)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            HStack {
                Text(numberUnit.description)
            }
            .bold()
            .foregroundStyle(.primary)
        }
        .frame(width: 180)
        .padding(.horizontal)
        
    }
}

#Preview {
    VStack {
        HStack {
            StatisticView(numberUnit: DistanceUnit(25, .km), description: "Total Distance")
                .infoDetails("Distance Walked", "Total distance you've walked so far. Total distance you've walked so far. Total distance you've walked so far.")
            Spacer()
            StatisticView(numberUnit: DistanceUnit(25, .km), description: "Total Distance")
                .infoDetails("Distance Walked", "Total distance you've walked so far. Total distance you've walked so far. Total distance you've walked so far.")
        }
        HStack (alignment: .top) {
            StatisticView(numberUnit: WeightUnit(6.7, .kg), description: "Base Weight")
            Spacer()
            StatisticView(numberUnit: DistanceUnit(25, .km), description: "Long Title Long Title Title Long Title")
        }
        Spacer()
    }
    .padding(.trailing)
}
