//
//  StorageService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 06/08/2025.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol {
    
    /**
     Saves an image to storage
     - Parameters:
        - path: full path of the storage location where the file will be stored
        - data: the image data
        - contentType: mime type, eg image/j-peg
     
     - Returns: the downloadable url for the image
     */
    func saveImage(_ path: String, data: Data, contentType: String?) async throws -> URL
    
    /**
     Deletes the image located at the path from Storage
     
     - Parameters:
        - path: full path where the image data to be deleted is located
     */
    func deleteImageFromStorage(_ path: String) async throws
}

class StorageService: StorageServiceProtocol {
    
    func saveImage(_ path: String, data: Data, contentType: String?) async throws -> URL {
        print("saveing image to \(path) with contentType \(contentType ?? "unknown")...")
        
        let storageRef = Storage.storage().reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        print("saved, url = \(downloadURL.absoluteString)")
        return downloadURL
    }
    
    
    func deleteImageFromStorage(_ path: String) async throws {
        print("deleting from Storage at \(path)...")
        
        let storageRef = Storage.storage().reference(withPath: path)
        try await storageRef.delete()
        print("deleted")
    }
}

class StorageSerivceMock: StorageServiceProtocol {
    func saveImage(_ path: String, data: Data, contentType: String?) async throws -> URL {
        return URL(string: "file:///path/to/mock/image")!
    }
    
    func deleteImageFromStorage(_ path: String) async throws {
        // do nothing
    }
}
