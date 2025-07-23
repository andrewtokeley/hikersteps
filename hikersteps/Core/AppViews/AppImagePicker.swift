//
//  AppImagePicker.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 21/07/2025.
//

import PhotosUI
import SwiftUI

struct AppImagePicker: View {
    @FocusState var focused: Bool
    
    @State private var selectedImageItem: PhotosPickerItem?
    @State var image: Image?
    
    var body: some View {
        
        PhotosPicker(selection: $selectedImageItem)
        {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                VStack {
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                    Text("Add Photo")
                        .bold()
                    Text("Tap to add a photo")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
                .styleBorderLight(focused: true)
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selectedImageItem) {
            Task {
                if let loaded = try? await selectedImageItem?.loadTransferable(type: Image.self) {
                    image = loaded
                } else {
                    print("Failed")
                }
            }
        }
        .onAppear {
            focused = true
        }
    }
}

#Preview {
    AppImagePicker()
}
