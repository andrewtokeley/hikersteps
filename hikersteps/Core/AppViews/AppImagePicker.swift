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
    
    @Binding var storageImages: [StorageImage]
    
    @State private var selectedImage: Image?
    
    var body: some View {
        
        if let url = storageImages.first?.storageUrl {
            // There is an image
            HStack {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .clipped()
                } placeholder: {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .tint(.accentColor)
                        .styleBorderLight(focused: true)
                }
                Spacer()
                VStack {
                    Button("Remove") {
                        storageImages.removeFirst()
                    }
                    Button("Replace") {
                        
                    }
                }
            }
        // No image exists
        } else {
            PhotosPicker(selection: $selectedImageItem) {
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
            .onChange(of: selectedImageItem) {
                Task {
                    if let loaded = try? await selectedImageItem?.loadTransferable(type: Image.self) {
                        selectedImage = loaded
                    } else {
                        print("Failed")
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var image1 = [StorageImage.sample]
    @Previewable @State var image2: [StorageImage] = []
    AppImagePicker(storageImages: $image1)
    AppImagePicker(storageImages: $image2)
}
