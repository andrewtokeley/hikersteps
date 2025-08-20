//
//  StorageImage.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
/*
 A StorageImage is how images are defined on a CheckIn document. They contain all the information required to display via a url and locate the data in Storage.
 */
struct StorageImage:Codable, Equatable, FirestoreEncodable  {
    /**
     The name of the file in Storage, including it's extension.
     
     Deprecated: Not Used
     */
    var name: String?
    
    /**
     Optional caption that will be displayed when the image is previewed
     */
    var caption: String?
    
    /**
     Full path to the location in Firebase Storage where the image is saved.
     
     - SeeAlso: to get the folder where images for a checkin are stored use, `CheckIn.getStorageFolder()`
     
     - SeeAlso: to get the path where a number image should be stored, user `getStoragePathForImage(_ index: Int)`
     */
    var storagePath: String?
    
    /**
     A URL to the stored image that can be used to present the image in app
     */
    var storageUrl: String?
    
    static var sampleLongImage: StorageImage {
        return .init(
            name: "photo.jpg",
            caption: "This is a sample image",
            storagePath: "images/HJDIBR65ZjR3BaRFXLf8c5DrxJ93/SYZ3RpPyO4tkiLfxllqo/0Z859sAJcWeFendu5yfW/1",
            storageUrl: "https://firebasestorage.googleapis.com/v0/b/istayedhere-dev.appspot.com/o/images%2F1OZ0zM1OHac848DLo9oyifKFEg13%2F3yJiqgUPlqeEnyhdQsr8%2FtMDKXsm9pDOmGIfVNtP1%2F2?alt=media&token=6c58dcf2-3510-4d63-abae-f74946449326"
        )
    }
    
    static var sample: StorageImage {
        return .init(
            name: "photo.jpg",
            caption: "This is a sample image",
            storagePath: "images/HJDIBR65ZjR3BaRFXLf8c5DrxJ93/SYZ3RpPyO4tkiLfxllqo/0Z859sAJcWeFendu5yfW/1",
            storageUrl: "https://firebasestorage.googleapis.com/v0/b/istayedhere-dev.appspot.com/o/images%2F1OZ0zM1OHac848DLo9oyifKFEg13%2Fta%2F345fLtKovtKY3DkxroHr%2F1?alt=media&token=47e85d30-8f6b-4b24-b23d-70970e908f34"
        )
    }
}

