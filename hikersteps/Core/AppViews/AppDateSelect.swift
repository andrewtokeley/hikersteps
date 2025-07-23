//
//  DateSelect.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 19/07/2025.
//

import SwiftUI

struct AppDateSelect: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    @State private var editDate: Date
    
    var title: String
    
    init(selectedDate: Binding<Date>, title: String) {
        _selectedDate = selectedDate
        self.title = title
        self.editDate = selectedDate.wrappedValue
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
                        .foregroundStyle(.gray)
                }
            }
            .padding()
            
            Divider()
            
            DatePicker("", selection: $editDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
            
            Spacer()
            
            Divider().padding()
            
            HStack {
                
                Button("Cancel") {
                    dismiss()
                }
                .padding(.horizontal, 16)
                .styleForegroundPrimary()

                Spacer()

                Button("OK") {
                    selectedDate = editDate
                    dismiss()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    
    AppDateSelect(selectedDate: $selectedDate, title: "Select Date")
}
