//
//  NewCheckInDialog.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 10/07/2025.
//

import SwiftUI

struct NewCheckInDialog: View {
    @Environment(\.dismiss) private var dismiss
    
    var info: String?
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("New CheckIn?")
                    .font(.title)
                Spacer()
                Button(action: {
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
                    dismiss()
                }) {
                    Text("Cancel")
                }
                .capsuleStyled(background: .gray, foreground: .white)
                Button(action: {
                    dismiss()
                }) {
                    Text("I Stayed Here")
                }
                .capsuleStyled(background: .blue, foreground: .white)
            }
            .padding(.top)
            Spacer()
        }

        .padding()
    }
}

#Preview {
    NewCheckInDialog(info: "Point of interest")
}
