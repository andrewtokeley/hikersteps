//
//  AppRadioButton.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 09/08/2025.
//

import SwiftUI

struct RadioOption: Identifiable, Hashable {
    var id = UUID().uuidString
    var title: String
    var subTitle: String? = nil
    var icon: String // system image name or asset name
    
    var hasSubTitle: Bool {
        return !(subTitle?.isEmpty ?? true)
    }
}

struct RadioButtonGroup: View {
    let options: [RadioOption]
    @Binding var selected: RadioOption?
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                Button {
                    selected = option
                } label: {
                    VStack (alignment: .leading) {
                        HStack {
                            Image(systemName: option.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24, height: 24)
                            
                            Text(option.title)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Custom "radio" indicator
                            Circle()
                                .stroke(selected == option ? Color.blue : Color.gray, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(selected == option ? Color.accentColor : Color.clear)
                                        .frame(width: 12, height: 12)
                                )
                        }
                        if option.hasSubTitle {
                            Text(option.subTitle!)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selected == option ? Color.accentColor : Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
