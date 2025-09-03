//
//  CheckInService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation
import CoreLocation

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

protocol CheckInServiceProtocol {
    
    func getCheckIns(uid: String, journalId: String) async throws -> [CheckIn]
    
    /**
     Updates an existing checkin.
     */
    func updateCheckIn (checkIn: CheckIn) async throws
    
    /**
     Adds a new checkIn.
     
     The checkIn must include at least the following fields
        - uid
        - adventureId (hikeId)
     - Returns: The id of the new CheckIn.
     */
    func addCheckIn(checkIn: CheckIn) async throws -> String
    
    /**
     Deletes the checkin AND it's associated image(s) from storage
     */
    func deleteCheckIn(checkIn: CheckIn) async throws
    
    func addImage(to checkIn: CheckIn, imageData: Data, contentType: String, caption: String) async throws
    
    func deleteImage(from checkIn: CheckIn, at path: String) async throws
    
    func deleteAllImages(from checkIn: CheckIn) async throws
    
    func save(manager: CheckInManager) async throws
    
    func addCheckInDeletes(to batch: WriteBatch, for hike: Journal) async throws
}

class CheckInService: CheckInServiceProtocol {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    let collectionName = "check-ins"
    
    func deleteCheckIn(checkIn: CheckIn) async throws {
        guard let id = checkIn.id else { throw ServiceError.generalError("CheckIn must have an id") }
        
        // first delete the images from storage
        try await self.deleteAllImages(from: checkIn)

        // delete the checkin document
        let docRef = db.collection(collectionName).document(id)
        try await docRef.delete()
    }
    
    func deleteAllImages(from checkIn: CheckIn) async throws {
        if let folder = checkIn.getStorageFolder() {
            let folderRef = storage.reference(withPath: folder)
            let result = try await folderRef.listAll()
            for item in result.items {
                let storageRef = storage.reference(withPath: item.fullPath)
                try await storageRef.delete()
            }
        }
    }
    
    func deleteImage(from checkIn: CheckIn, at path: String) async throws {
        let storageRef = storage.reference(withPath: path)
        try await storageRef.delete()
        
        // clear image from checkin
        var copy = checkIn
        copy.images = []
        try await updateCheckIn(checkIn: copy)
    }
    
    func addImage(to checkIn: CheckIn, imageData: Data, contentType: String, caption: String) async throws {
        guard let path = checkIn.getStoragePathForImage(1) else { throw ServiceError.generalError("Can't define image path") }
        
        let storageRef = storage.reference(withPath: path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        // we only allow on image at the moment
        let newStorageImage = StorageImage(caption: caption, storagePath: path, storageUrl: downloadURL.absoluteString)
        
        var copy = checkIn
        copy.images = [newStorageImage]
        try await updateCheckIn(checkIn: copy)
        
    }
    
    func addCheckIn(checkIn: CheckIn) async throws -> String {
        guard !checkIn.journalId.isEmpty else { throw ServiceError.missingField("journalId") }
        guard !checkIn.uid.isEmpty else { throw ServiceError.missingField("uid") }
        
        let newDocRef = db.collection(collectionName).document()
        try await newDocRef.setData(checkIn.toDictionary(), merge: false)
        return newDocRef.documentID
    }
    
    func updateCheckIn (checkIn: CheckIn) async throws {
        guard let id = checkIn.id else { throw ServiceError.missingField("id") }
        
        try await db.collection(collectionName).document(id)
            .setData(checkIn.toDictionary(), merge: true)
    }
    
    func addCheckInDeletes(to batch: WriteBatch, for hike: Journal) async throws {
        guard let id = hike.id else { return }
        
        let uid = hike.uid
        
        let checkIns = try await getCheckIns(uid: uid, journalId: id)
        for checkIn in checkIns {
            guard let id = checkIn.id else { continue }
            let docRef = db.collection(collectionName).document(id)
            batch.deleteDocument(docRef)
        }
    }
    
    func save(manager: CheckInManager) async throws {
    
        let changes = manager.changes
        
        let batch = db.batch()
        
        // Add new CheckIns
        for checkIn in changes.added {
            let newDocRef = db.collection(collectionName).document()
            if let dictionary = try? checkIn.toDictionary() {
                batch.setData(dictionary, forDocument: newDocRef)
            }
        }
        
        // Update existing CheckIns
        for checkIn in changes.modified {
            guard let id = checkIn.id else { continue }
            let docRef = db.collection(collectionName).document(id)
            if let dictionary = try? checkIn.toDictionary() {
                batch.setData(dictionary, forDocument: docRef, merge: true)
            }
        }
        
        // Delete removed CheckIns
        for checkIn in changes.removed {
            guard let id = checkIn.id else { continue }
            let docRef = db.collection(collectionName).document(id)
            batch.deleteDocument(docRef)
        }
        
        // Commit the batch
        try await batch.commit()
    }
    
    func getCheckIns(uid: String, journalId: String) async throws -> [CheckIn] {
        
        let snapshot = try await db.collection(collectionName)
            .whereField("uid", isEqualTo: uid)
            .whereField("adventureId", isEqualTo: journalId)
            .order(by: "date", descending: false)
            .getDocuments()
        
        do {
            let checkins = try snapshot.documents.compactMap { doc -> CheckIn? in
                var item = try doc.data(as: CheckIn.self)
                item.id = doc.documentID
                return item
            }
            return checkins
        } catch {
            throw ServiceError.unknownError
        }
    }
}

extension CheckInService {
    class Mock: CheckInServiceProtocol {
        
        func deleteCheckIn(checkIn: CheckIn) async throws {
        }
        
        func deleteImage(from checkIn: CheckIn, at path: String) async throws {
            
        }
        
        
        func deleteAllImages(from checkIn: CheckIn) async throws {
            
        }
        
        func addImage(to checkIn: CheckIn, imageData: Data, contentType: String, caption: String) async throws {
            print("addImage")
        }
        
        func updateCheckIn(checkIn: CheckIn) async throws {
            print("updateCheckIn")
        }
        
        func addCheckIn(checkIn: CheckIn) async throws -> String {
            print("addCheckIn")
            return ""
        }
        
        func addCheckInDeletes(to batch: WriteBatch, for hike: Journal) async throws {
            return
        }
        
        func getCheckIns(uid: String, journalId: String) async throws -> [CheckIn] {
            return [
                CheckIn(uid: "123", journalId: "1", id: "4", location: Coordinate(latitude: -41.12, longitude: 174.7787), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", distance: Measurement(value: 10, unit: .kilometers), date: Date(), images: [StorageImage.sample]),
                CheckIn(uid: "123", journalId: "1", id: "0", location: Coordinate(latitude: -41.16, longitude: 174.7787), title: "Twolight Campsite", notes: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam",  distance: Measurement(value: 21, unit: .kilometers), date: Date(), accommodation: LookupItem(id: "1", name: "Tent", imageName: "tent")),
                CheckIn(uid: "123", journalId: "1", id: "1", location: Coordinate(latitude: -41.19, longitude: 174.7787), title: "Brakenexk Speed Camp",  distance: Measurement(value: 35, unit: .kilometers), numberOfRestDays: 2, date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
                CheckIn(uid: "123", journalId: "1", id: "24", location: Coordinate(latitude: -41.29, longitude: 174.7787), title: "Wild Camping", distance: Measurement(value: 42, unit: .kilometers), date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!),
                CheckIn(uid: "123", journalId: "1", id: "3", location: Coordinate(latitude: -41.39, longitude: 174.7787), title: "Cherokee Point Camp",  distance: Measurement(value: 15, unit: .kilometers), date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
            ]
        }
        
        func save(manager: CheckInManager) async throws {
            // do nothing
            return
        }
    }
}


