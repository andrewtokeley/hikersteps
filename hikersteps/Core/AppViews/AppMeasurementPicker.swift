//
//  AppMeasurementPicker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 24/08/2025.
//

import SwiftUI

/**
 A view that can be bound to any Measurement value
 */
struct AppMeasurementPicker<T>: View where T: Dimension {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var measurement: Measurement<T>
    @State var editMeasurement: Measurement<T>
    var title: String
    
    init (measurement: Binding<Measurement<T>>, title: String) {
        self._measurement = measurement
        self.title = title
        self.editMeasurement = Measurement<T>(value:  Double(Int(measurement.wrappedValue.value)), unit: measurement.wrappedValue.unit)
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
            
            Divider()
            
            HStack {
                Picker(title, selection: $editMeasurement.value) {
                    ForEach(0..<100) { number in
                        Text("\(number)").tag(Double(number))
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                Text(editMeasurement.unit.symbol)
                    .frame(height: 150)
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
                    //numberUnit = editNumberUnit
                    measurement = Measurement<T>(value: editMeasurement.value, unit: editMeasurement.unit)
                    print("updated binding \(measurement)")
                    dismiss()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var distance = Measurement<UnitLength>(value: 10.654, unit: .kilometers)
    AppMeasurementPicker<UnitLength>(measurement: $distance, title: "Pick a distanced")
}
