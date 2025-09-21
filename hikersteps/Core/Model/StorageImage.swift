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
     
     Deprecated: Not Used, but could be in firestore still for some old records so keeping here for now
     */
    //var name: String
    
    /**
     Optional caption that will be displayed when the image is previewed
     */
    var caption: String
    
    /**
     Full path to the location in Firebase Storage where the image is saved.
     
     - SeeAlso: to get the folder where images for a checkin are stored use, `CheckIn.getStorageFolder()`
     
     - SeeAlso: to get the path where a number image should be stored, user `getStoragePathForImage(_ index: Int)`
     */
    var storagePath: String
    
    /**
     A URL to the stored image that can be used to present the image in app
     */
    var storageUrl: String

    enum CodingKeys: String, CodingKey {
        
        case caption
        case storagePath
        case storageUrl
    }
    
    /**
     This initialiser it typically only used for testing purposes. For App use it's more common to use Checkin(uid, adventureId)
     */
    init(caption: String, storagePath: String, storageUrl: String) {
        self.caption = caption
        self.storagePath = storagePath
        self.storageUrl = storageUrl
    }
        
    /**
     Initiaiser used by firestore to rehydrate struct
     */
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.caption = try container.decodeIfPresent(String.self, forKey: .caption) ?? ""
        self.storagePath = try container.decodeIfPresent(String.self, forKey: .storagePath) ?? ""
        self.storageUrl = try container.decodeIfPresent(String.self, forKey: .storageUrl) ?? ""
    }
    
    /**
     Convenience method to create a blank image struct that we can still bind to controls (e.g. the StorageImage view.)
     */
    static var empty: StorageImage {
        return StorageImage(caption: "", storagePath: "", storageUrl: "")
    }
    var hasImage: Bool {
        return storageUrl != "" && storagePath != ""
    }
    
    static var sampleLongImage: StorageImage {
        return .init(
            caption: "This is a sample image",
            storagePath: "images/HJDIBR65ZjR3BaRFXLf8c5DrxJ93/SYZ3RpPyO4tkiLfxllqo/0Z859sAJcWeFendu5yfW/1",
            storageUrl: "https://hikewithgravity.com/sites/default/files/styles/horiz_md_2x/public/blog-images/body-images/2021-02/day154-bull-lake.jpeg?itok=QTR1M2lD"
        )
    }
    
    static var sample: StorageImage {
        return .init(
            caption: "This is a sample image",
            storagePath: "images/HJDIBR65ZjR3BaRFXLf8c5DrxJ93/SYZ3RpPyO4tkiLfxllqo/0Z859sAJcWeFendu5yfW/1",
            storageUrl: "https://firebasestorage.googleapis.com/v0/b/istayedhere-dev.appspot.com/o/images%2F1OZ0zM1OHac848DLo9oyifKFEg13%2Fta%2F345fLtKovtKY3DkxroHr%2F1?alt=media&token=47e85d30-8f6b-4b24-b23d-70970e908f34"
        )
    }
}

