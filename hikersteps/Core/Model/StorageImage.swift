//
//  StorageImage.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation

struct StorageImage:Codable {
    var name: String?
    var caption: String?
    var storagePath: String?
    var storageUrl: String?
    
    static var sample: StorageImage {
        return .init(
            name: "Sample Image",
            caption: "This is a sample image",
            storagePath: "sample-image.jpg",
            storageUrl: "https://firebasestorage.googleapis.com/v0/b/istayedhere-dev.appspot.com/o/images%2F1OZ0zM1OHac848DLo9oyifKFEg13%2Fta%2F345fLtKovtKY3DkxroHr%2F1?alt=media&token=47e85d30-8f6b-4b24-b23d-70970e908f34"
        )
    }
}

