//
//  StepperManual.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 15/07/2025.
//

import SwiftUI

struct AppStepperManual: View {
    @Binding var value: Int
    @FocusState private var isEditingFocus: Bool
    @State private var isEditing = false
    
    var minimumValue: Int = 0
    var maximumValue: Int = 100
    var label: String = ""
    var unit: String?
    var systemImage: String?
    
    private var range: ClosedRange<Int> {
        return minimumValue...maximumValue
    }
    
    init(value: Binding<Int>, label: String = "", minimumValue: Int = 0, maximumValue: Int = 100, unit: String? = nil, systemImage: String? = nil) {
        
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.label = label
        self.unit = unit
        self.systemImage = systemImage
        self._value = value
    }
    
    var body: some View {
        
        HStack {
            if let systemImage = systemImage {
                Label(label, systemImage: systemImage).foregroundStyle(.primary)
            } else {
                Text(label).foregroundStyle(.primary)
            }
            
            Spacer()
            
            Button( action: decrement ) {
                Image(systemName: "minus.circle")
            }.buttonStyle(.plain).foregroundStyle(.blue)
            
            if isEditing {
                TextField("", value: $value, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .onSubmit { isEditing = false }
                    .frame(width:100, height: 40)
                    .focused($isEditingFocus)
                    .onChange(of: isEditingFocus) { oldValue, newValue in
                        if newValue == false {
                            self.isEditing = false
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            } else {
                HStack {
                    Text("\(value) ").bold()
                    if let unit = unit {
                        Text(unit)
                    }
                }
                .onTapGesture {
                    isEditing = true
                    isEditingFocus = true
                }
                .frame(width:100, height: 40)
                .padding(.leading)
                .padding(.trailing)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
            
            Button( action: increment ) {
                Image(systemName: "plus.circle")
            }.buttonStyle(.plain).foregroundStyle(.blue)
        }
        .onAppear {
            // ensure the user didn't set the bound value out of range
            self.setValue(value)
        }
        .onChange(of: value) { oldValue, newValue in
            // ensure the user doesn't type in an out of range value
            setValue(newValue)
        }
    }
    
    private func setValue(_ value: Int) {
        if !range.contains(value) {
            print("clamping \(value)")
            self.value = value.clamped(to: range)
        }
    }
    private func increment() {
        if value < maximumValue {
            value += 1
        }
    }
    
    private func decrement() {
        if value > minimumValue {
            value -= 1
        }
    }
}

#Preview {
    StepperManualPreviewWrapper()
}

struct StepperManualPreviewWrapper: View {
    @State private var value1 = 123
    @State private var value2 = 1
    @State private var valueTooHigh = 1000
    @State private var valueTooLow = -10
    
    var body: some View {
        
            Form {
                Section {
                    AppStepperManual(value: $value1, label: "With Label", unit: "miles", systemImage: "figure.walk")
                    AppStepperManual(value: $value1, unit: "miles", systemImage: "figure.walk")
                    AppStepperManual(value: $valueTooHigh, label: "Too High", maximumValue: 10, unit: "day(s)", systemImage: "calendar")
                    AppStepperManual(value: $valueTooLow, label: "Too Low", minimumValue: 0, unit: "day(s)", systemImage: "calendar")
                }
            }
        VStack {
            AppStepperManual(value: $value1, label: "Distance", unit: "miles", systemImage: "figure.walk")
                .padding()
            AppStepperManual(value: $value2, label: "Distance", unit: "miles", systemImage: "figure.walk")
                .padding()
        }
        
        
    }
}
