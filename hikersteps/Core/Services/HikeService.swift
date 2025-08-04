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
    func fetchHikes() async throws -> [Hike]
}

class HikerService: HikerServiceProtocol {
    
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
}

class HikerServiceMock: HikerServiceProtocol {
    func updateStatistics(hikeId: String, statistics: HikeStatistics) async throws {
        return
    }
    
    func fetchHikes() async throws -> [Hike] {
        var hike1 = Hike(name: "Tokes on the TA", description: "Let's do this!", startDate: Date())
        hike1.id = "1"
        hike1.statistics = HikeStatistics.sample
        var hike2 = Hike(name: "Bibbulmun 2025", description: "Where are all the snakes", startDate: Date())
        hike2.id = "2"
        hike2.statistics = HikeStatistics.sample
        return [hike1, hike2]
    }
}
