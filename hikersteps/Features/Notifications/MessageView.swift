//
//  MessageView.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 07/08/2025.
//

import SwiftUI

struct MessageView: View {
    var message: String
    var body: some View {
        NavigationStack {
            VStack {
                Text(message)
                Spacer()
            }
        }
        .navigationTitle("Message")
    }
}

#Preview {
    MessageView(message: """
                Thanks for being amazing. Thanks for being amazing. Thanks for being amazing. Thanks for being amazing.Thanks for being amazing. Thanks for being amazing.Thanks for being amazing. Thanks for being amazing.Thanks for being amazing. Thanks for being amazing.

                Thanks for being amazing.

                Yours sincerely
                Tokes
""")
}
