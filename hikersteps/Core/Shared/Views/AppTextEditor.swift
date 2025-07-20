//
//  AppTextEditor.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 19/07/2025.
//

import SwiftUI

struct AppTextEditor: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var placeholder: String = ""
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($isFocused)
                    .styleBorderLight(focused: isFocused)
                 
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.gray).opacity(0.5)
                        .font(.body)
                        .padding(.top, 25)
                        .padding(.leading, 20)
                }
            }
            
            HStack {
                Spacer()
                Text("\(text.count)/1000 characters")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    AppTextEditor(text: $text, placeholder: "Write something about your day")
}

