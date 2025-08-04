//
//  InfoDetails.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 31/07/2025.
//

import Foundation
import SwiftUI

extension View {
    func infoDetails(_ title: String, _ details: String) -> some View {
        modifier(InfoDetailsModifier(title: title, details: details))
    }
}

struct InfoDetailsModifier: ViewModifier {
    let title: String
    let details: String
    
    @State private var showingSheet = false
    
    func body(content: Content) -> some View {
        ZStack (alignment: .topTrailing) {
            content
            
            Button(action: {
                showingSheet = true
            }) {
                Image(systemName: "info.circle")
            }.offset(x: -12)
        }
        .fixedSize()
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                VStack {
                    Text(details)
                        .font(.body)
                    Spacer()
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSheet = false
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.2)])
            .presentationDragIndicator(.hidden)
        }
    }
}
