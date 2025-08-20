//
//  AppNumberPicker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import SwiftUI

struct AppNumberPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    /**
     The number bound to the view
     */
    @Binding private var number: Int
    
    /**
     The unit bound to the view, this is optional and only relevant if the user supplies a unit list
     */
    private var unit: Binding<Unit>?
    
    /**
     Internal state to track the selected number, only when OK is selected is the bound number set to this.
     */
    @State private var editNumber: Int
    
    /**
     Internal state to track the selected unit, if multiple units are supplied. Only when OK is selected is the bound unit set to this.
     */
    @State private var editUnit: Unit?
    
    /**
     The title to display at the top of the view
     */
    var title: String
    
    /**
    Optional text to place under the main title
     */
    var subTitle: String?
    
    /**
     Optional array of units to select from. Can be a single item array, if no selection required but the unit should still be displayed.
     */
    var units: [Unit] = []
    
    init (title: String, number: Binding<Int>, subTitle: String? = nil, units: [Unit] = [], unit: Binding<Unit>? = nil ) {
        self._number = number
        self.unit = unit
        self.title = title
        self.subTitle = subTitle
        self.units = units
        self.editNumber = number.wrappedValue
        self.editUnit = unit?.wrappedValue
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title)
                Spacer()
                Button(action: {
                    dismiss()
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            if let subTitle = subTitle {
                Text(subTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
            
            HStack {
                Picker(title, selection: $editNumber) {
                    ForEach(0..<100) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                if (units.count > 1) {
                    Picker(title, selection: $editUnit) {
                        ForEach(units) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                } else if (units.count == 1) {
                    Text("\(units.first!.rawValue)")
                        .frame(height: 150)
                }
                
            }
            
            Spacer()
            
            Divider().padding()
            
            HStack {
                
                Button("Cancel") {
                    dismiss()
                }
                .padding(.horizontal, 16)
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("OK") {
                    // Write the edited values back to the bound properties
                    number = editNumber
                    if let unit = unit, let editUnit = editUnit {
                        unit.wrappedValue = editUnit
                    }
                    dismiss()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var number: Int = 4
    @Previewable @State var unit: Unit = .weeks
    AppNumberPicker(title: "Zero Days", number: $number, subTitle: "Somethin to say about the numbers...", units:[.days, .weeks], unit: $unit)
}
