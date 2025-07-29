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
    private var onConfirm: (() -> Void)?
    var info: String?
    
    init(info: String? = nil, onCancel: (() -> Void)? = nil, onConfirm: (() -> Void)? = nil) {
        self.info = info
        self.onCancel = onCancel
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("New Check-In")
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
            if let info
                = info {
                Text(info)
                    .font(.subheadline)
            }
            HStack {
                Button(action: {
                    onCancel?()
                    dismiss()
                }) {
                    Text("Cancel")
                }
                .capsuleStyled(background: .gray, foreground: .white)
                Spacer()
                Button(action: {
                    onConfirm?()
                    dismiss()
                }) {
                    Text("Create...")
                }
                .capsuleStyled(background: .blue, foreground: .white)
            }
            .padding(.top)
            Spacer()
        }
        .padding()
    }
    
    func onCancel(_ handler: @escaping (() -> Void)) -> NewCheckInDialog {
        var copy = self
        copy.onCancel = handler
        return copy
    }
    
    func onConfirm(_ handler: @escaping (() -> Void)) -> NewCheckInDialog {
        var copy = self
        copy.onConfirm = handler
        return copy
    }
}

#Preview {
    NewCheckInDialog(info: "Point of interest")
}
