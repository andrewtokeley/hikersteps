//
//  AppNumberPicker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 22/07/2025.
//

import SwiftUI

/**
 Simple picker to let the user select a numbe (like "days")
 */
struct AppNumberPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    /**
     The number bound to the view
     */
    @Binding private var number: Int
    
    /**
     Internal state to track the selected number, only when OK is selected is the bound number set to this.
     */
    @State private var editNumber: Int
    
    /**
     The unit to display
     */
    var unitDescription: String = ""
    
    /**
     The title to display at the top of the view
     */
    var title: String
    
    
    init (title: String, number: Binding<Int>, unitDescription: String) {
        self.title = title
        self._number = number
        self.editNumber = number.wrappedValue
        self.unitDescription = unitDescription
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
                Picker(title, selection: $editNumber) {
                    ForEach(0..<100) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                
                Text(unitDescription)
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
                    number = editNumber
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
    AppNumberPicker(title: "Zero Days", number: $number, unitDescription: "days")
}
