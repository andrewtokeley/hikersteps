//
//  NewCheckInDialog.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 10/07/2025.
//

import SwiftUI

struct NewCheckInDialog: View {
    @Environment(\.dismiss) private var dismiss
    
    private var onCancel: (() -> Void)?
    private var onConfirm: ((Date) -> Void)?
    private var isDateAvailable: ((Date) -> Bool)?
    
    @State private var canConfirm: Bool = false
    @State private var proposedDate: Date
    @State private var dateMessage: String = ""
    
    var info: String? = nil
    
    init(info: String? = nil, proposedDate: Date = Date()) {
        _proposedDate = State(initialValue: proposedDate)
        self.info = info
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .top) {
                Text("New Journal Entry")
                    .font(.title)
                Spacer()
                Button(action: {
                    onCancel?()
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .font(.system(size: 30, weight: .thin))
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                DatePicker("", selection: $proposedDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(canConfirm ? .gray : .red, lineWidth: 1)
                    )
                    .onChange(of: proposedDate) {
                        // check if this date is available
                        print("changed")
                        self.canConfirm = isDateAvailable?(proposedDate) ?? false
                    }
                    .onAppear {
                        self.canConfirm = isDateAvailable?(proposedDate) ?? false
                    }
                if (!canConfirm) {
                    Text("Date unavailable")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Text("You can create a journal entry for every day of your adventure!")
                .padding(.top,1)

            if let info
                = info {
                Text(info)
                    .font(.subheadline)
                    .padding(.top)
            }
            
            HStack {
                
                AppCapsuleButton("Cancel") {
                    dismiss()
                }
                .capsuleStyle(.white)
                Spacer()
                AppCapsuleButton("Continue") {
                    onConfirm?(proposedDate)
                    dismiss()
                }
                .capsuleStyle(.filled)
                .disabled(!canConfirm)
            }
            .padding(.top, 30)
            Spacer()
        }
        .padding()
    }
    
    func onCancel(_ handler: (() -> Void)?) -> NewCheckInDialog {
        var copy = self
        copy.onCancel = handler
        return copy
    }
    
    func onConfirm(_ handler: ((Date) -> Void)?) -> NewCheckInDialog {
        var copy = self
        copy.onConfirm = handler
        return copy
    }
    
    func isDateAvailable(_ handler: ((Date) -> Bool)?) -> NewCheckInDialog {
        var copy = self
        copy.isDateAvailable = handler
        return copy
    }
}

#Preview {
    NewCheckInDialog(proposedDate: Date())
        .isDateAvailable { date in
            return date.compare(Date()) == .orderedAscending
    }
}
