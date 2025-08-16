//
//  LookupService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 16/07/2025.
//

import Foundation
import FirebaseFirestore

protocol LookupServiceProtocol {
    func getAccommodationLookups() async throws -> [LookupItem]
}

class LookupService: LookupServiceProtocol {
    
    func getAccommodationLookups() async throws -> [LookupItem] {
        let result = try await getLookups(documentKey: "ACCOMMODATION")
        return result
    }
    
    private func getLookups(documentKey: String) async throws -> [LookupItem] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("lookups")
            .document(documentKey).collection("keys")
            .getDocuments()
        do {
            let lookups = try snapshot.documents.compactMap { doc in
                var item = try doc.data(as: LookupItem.self)
                item.id = doc.documentID
                return item
            }
            return lookups.sorted { a, b in
                a.order < b.order
            }
        } catch {
            throw error
        }
    }
}

class LookupServiceMock: LookupServiceProtocol {
    func getAccommodationLookups() async throws -> [LookupItem] {
        return [
            LookupItem(id: "1", name: "Tent", imageName: "carpenter"),
            LookupItem(id: "2", name: "Hotel", imageName: "cabin"),
            LookupItem(id: "3", name: "Trail Angel", imageName: "airline-seat-flat")
        ]
    }
}
