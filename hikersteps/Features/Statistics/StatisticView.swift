//
//  StatisticView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import SwiftUI

struct StatisticView: View {
    var numberUnit: NumberUnitProtocol
    var description: String
    
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
                
                Text(numberUnit.description)
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
                StatisticView(numberUnit: DistanceUnit(25, .km), description: "Total Distance")
                StatisticView(numberUnit: DistanceUnit(25, .km), description: "Total Distance")
            }
            .frame(width: 140)
            .background(.red)
        }
        
        HStack (alignment: .top) {
            Group {
                StatisticView(numberUnit: WeightUnit(6.7, .kg), description: "Base Weight")
                
                StatisticView(numberUnit: DistanceUnit(25, .km), description: "Long Title Long Title Title Long Title")
            }
            .frame(width: 140)
            .background(.blue)
        }
    }
    .padding()
}
