import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct StorageImageEditorView: View {
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isLoadingImage = false
    @State private var isReadingDataFromURL = true
    @State private var image: Image?
//    @State private var caption: String
    
    @Binding var storageImage: StorageImage
    
    //var imageURL: String?
    
    private var onImageDataChanged: ((Data, String?) -> Void)? = nil
    private var onRemove: (() -> Void)? = nil
    
    init(storageImage: Binding<StorageImage>) {
        _storageImage = storageImage
        if _storageImage.storageUrl.wrappedValue.isEmpty {
            _isReadingDataFromURL = State(initialValue: false)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Group {
                // we're loading the image from url
                if isReadingDataFromURL {
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    // we have an image preview to display
                } else if let image = self.image {
                    HStack {
                        ZStack (alignment: .topTrailing) {
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .frame(height: 120)
                            
                            AppCircleButton(size: 20, imageSystemName: "xmark", style: .filledOnImage) {
                                self.image = nil
                                self.onRemove?()
                            }
                            .style(.filledOnImage)
                            .padding(4)
                        }
                    }
                    // there is no image to display
                } else {
                    Button {
                        isLoadingImage = true
                    } label: {
                        VStack {
                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .bold()
                            Text("Tap to add a photo")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .styleBorderLight(focused: true)
            
            if let _ = self.image {
                TextField("Caption", text: $storageImage.caption)
                    .padding()
                    .styleBorderLight()
                    .padding(.vertical)
            }
        }
        
        .photosPicker(isPresented: $isLoadingImage, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) {
            Task {
                guard let item = selectedItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        self.image = Image(uiImage: uiImage)
                        let type = getContentType(from: item)
                        self.onImageDataChanged?(data, type)
                    }
                }
            }
        }
        .task {
            do {
                // initial load of the image supplied by url
                try await loadImageFromURLString(storageImage.storageUrl)
            } catch {
                ErrorLogger.shared.log(error)
            }
        }
    }
    
    func loadImageFromURLString(_ urlString: String) async throws {
        if !storageImage.storageUrl.isEmpty {
            if let url = URL(string: urlString) {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    self.image = Image(uiImage: uiImage)
                }
                self.isReadingDataFromURL = false
            }
        }
    }
    
    func onImageDataChanged(_ handler: ((_ data: Data, _ contentType: String?) -> Void)?) -> StorageImageEditorView {
        var copy = self
        copy.onImageDataChanged = handler
        return copy
    }
    
    func onRemove(_ handler: (() -> Void)?) -> StorageImageEditorView {
        var copy = self
        copy.onRemove = handler
        return copy
    }
    
    private func getContentType(from item: PhotosPickerItem) -> String? {
        guard let type = item.supportedContentTypes.first else { return nil }
        
        switch type {
        case UTType.jpeg:
            return "image/jpeg"
        case UTType.png:
            return "image/png"
        case UTType.heic:
            return "image/heic"
        case UTType.gif:
            return "image/gif"
        default:
            return type.preferredMIMEType
        }
    }

}

#Preview {
    @Previewable @State var image1: StorageImage = StorageImage.empty
    @Previewable @State var image2: StorageImage = StorageImage.sample
    StorageImageEditorView(storageImage: $image1)
        .onImageDataChanged { data, contentType in
            print("received image data - \(contentType ?? "unknow")")
        }
    StorageImageEditorView(storageImage: $image2)
}
