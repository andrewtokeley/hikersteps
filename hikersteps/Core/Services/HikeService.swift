//
//  HikeService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol JournalServiceProtocol {
    
    /**
     Update the statistics for the Journal. If there are no statistics for the Journal, they will be added, otherwise merged with the statistics that exist.
     
     - Parameters:
        - hikeId: id of the Journal
        - statistics: a ``HikeStatistics`` value
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws
    
    /**
     Updates the hike with a url of the image to be presented in the app for the Journal.
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func updateHeroImage(hikeId: String, urlString: String) async throws
    
    /**
     Returns all hikes that are associated with the logged in user. If the user is not logged in, the func returns an empty array.
     */
    func getHikes() async throws -> [Hike]
    
    /**
     Retrieves a hike instance. If not document exists with the given id the method returns nil.
     */
    func getHike(id: String) async throws -> Hike?
    
    /**
     Save the hike instance to firestore. If it exists it's updated, otherwise a new Hike document is created.
     
     - Parameters:
        - hike: Hike instance. If there is no id, it will be added as a new Hike
     
     - Returns: the id of the added or existing Hike
     - Throws: `ServiceError.unauthenticatedUser` if the caller is not authenticated
     
     */
    func updateHike (hike: Hike) async throws
    
    /**
     Adds a new Hike
     
     - Returns: the id of the new hike
     - Parameters:
        - hike: represents the `Hike` to add
     - Throws: a `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func addHike(hike: Hike) async throws -> String
    
    /**
     Deletes a hike AND all it's associated CheckIns and Storage images.
     
     - Parameters:
        - hike: Hike to be deleted
        - cascade: Default is true, which also deletes associated CheckIns and Images.
     
     - Important: If cascade is false, then only the Hike document is deleted, regardless of whether it has any CheckIns. This could leave orphaned CheckIns and is only supported for testing purposes.
     
     When cascade is set to true (the default), the delete action is a two step process
     - First the CheckIn images in Storage are deleted. We can't batch this and just do our best!
     - We then batch all of the Hike's CheckIns and the Hike document itself into a batch delete operation

     - Throws: a `ServiceError.unauthenticatedUser` if the caller is not authenticated
     
     */
    func deleteHike (hike: Hike, cascade: Bool) async throws
}

class JournalService: JournalServiceProtocol {
    let db = Firestore.firestore()
    let collectionName = "adventures"
    
    func getHike(id: String) async throws -> Hike? {
        let docRef = db.collection(collectionName).document(id)
        do {
            let snapshot = try await docRef.getDocument()
            if snapshot.exists {
                var item = try snapshot.data(as: Hike.self)
                item.id = snapshot.documentID
                return item
            } else {
                return nil
            }
        } catch {
            // this usually means you're ready a document that doesn't exist (usually only happens in testing)
            return nil
        }
    }
    
    func updateHeroImage(hikeId: String, urlString: String) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticateUser }
        
        let docRef = db.collection("adventures").document(hikeId)
        
        try await docRef.setData(["heroImageUrl": urlString], merge: true)
    }
    
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticateUser }
        
        let docRef = db.collection(collectionName).document(hikeId)
        
        try await docRef.setData ([
            "statistics": statistics.toDictionary()],
                                  merge: true)
    }
    
    func getHikes() async throws -> [Hike] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let snapshot = try await db.collection(collectionName)
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
        
        do {
            let hikes = try snapshot.documents.compactMap { doc -> Hike? in
                var item = try doc.data(as: Hike.self)
                item.id = doc.documentID
                return item
            }
            return hikes
        } catch {
            throw error
        }
    }

    func addHike(hike: Hike) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticateUser }
        let docRef = db.collection(collectionName).document()
        try await docRef.setData(hike.toDictionary())
        return docRef.documentID
    }
    
    func updateHike (hike: Hike) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticateUser }
        guard let id = hike.id else { throw ServiceError.missingField("id") }
        
        try await db.collection(collectionName)
            .document(id)
            .setData(hike.toDictionary(), merge: true)
    }
    
    func deleteHike (hike: Hike, cascade: Bool = true) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticateUser }
        guard let id = hike.id else { throw ServiceError.missingField("Hike id") }

        let batch = db.batch()
        
        if cascade {
            let checkInService = CheckInService()
            
            // delete all the images across all checkins (we can't do these in the batch)
            let checkIns = try await checkInService.getCheckIns(uid: hike.uid, adventureId: id)
            for checkIn in checkIns {
                try await checkInService.deleteAllImages(from: checkIn)
            }
            
            // add the hike's checkin deletes to the batch
            try await checkInService.addCheckInDeletes(to: batch, for: hike)
        }
        
        // Delete the hike document itself
        let docRef = db.collection(collectionName).document(id)
        batch.deleteDocument(docRef)
        
        try await batch.commit()
    }
}

extension JournalService {
    class Mock: JournalServiceProtocol {
        func updateHike(hike: Hike) async throws {
            //
        }
        
        func addHike(hike: Hike) async throws -> String {
            return ""
        }
        
        func getHike(id: String) async throws -> Hike? {
            return nil
        }
        
        func updateHeroImage(hikeId: String, urlString: String) async throws {
            return
        }
        
        func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws {
            return
        }
        
        func getHikes() async throws -> [Hike] {
            var hike1 = Hike(uid: "abc", name: "Tokes on the TA")
            hike1.uid = "abc"
            hike1.id = "1"
            hike1.description = "Let's do this!"
            hike1.statistics = HikeStatistics.sample
            return [hike1, Hike.sample]
        }
        
        func deleteHike (hike: Hike, cascade: Bool) async throws {
            // do nothing
        }
    }
}
