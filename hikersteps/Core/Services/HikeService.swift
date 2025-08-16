//
//  HikeService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol HikerServiceProtocol {
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws
    func updateHeroImage(hikeId: String, urlString: String) async throws
    func fetchHikes() async throws -> [Hike]
    func updateHike (hike: Hike) async throws -> String
}

class HikerService: HikerServiceProtocol {
    
    func updateHeroImage(hikeId: String, urlString: String) async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("adventures").document(hikeId)
        
        try await docRef.setData(["heroImageUrl": urlString], merge: true)
    }
    
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws {
        guard let _ = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("adventures").document(hikeId)
        
        try await docRef.setData ([
            "statistics": statistics.toDictionary()],
                                  merge: true)
    }
    
    func fetchHikes() async throws -> [Hike] {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ServiceError.unauthenticateUser
        }
        
        let db = Firestore.firestore()
        let snapshot = try await db.collection("adventures")
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
    
    func updateHike (hike: Hike) async throws -> String {
        let db = Firestore.firestore()
        var id: String
        
        if let _ = hike.id {
            id = hike.id!
        } else {
            let docRef = db.collection("adventures").document() // generates a new ID
            id = docRef.documentID
        }
        
        do {
            try await db.collection("adventures")
                .document(id)
                .setData(hike.toDictionary(), merge: true)
            
            return id
            
        } catch {
            throw error
        }
    }
}

class HikerServiceMock: HikerServiceProtocol {
    
    func updateHeroImage(hikeId: String, urlString: String) async throws {
        return
    }
    
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws {
        return
    }
    
    func fetchHikes() async throws -> [Hike] {
        var hike1 = Hike(name: "Tokes on the TA", description: "Let's do this!", startDate: Date())
        hike1.id = "1"
        hike1.statistics = HikeStatistics.sample
        return [hike1, Hike.sample]
    }
    
    func updateHike (hike: Hike) async throws -> String {
        return ""
    }
}
