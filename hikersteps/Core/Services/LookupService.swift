//
//  LookupService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 16/07/2025.
//

import Foundation
import FirebaseFirestore

struct LookupService {
    enum ServiceError: Error {
        case unknownError
    }
    
    static func getAccommodationLookups(completion: @escaping ([LookupItem]?, Error?) -> Void) {
        getLookups(documentKey: "ACCOMMODATION", completion: completion)
    }
    
    private static func getLookups(documentKey: String, completion: @escaping ([LookupItem]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("lookups")
            .document(documentKey).collection("keys")
            .order(by: "order", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                do {
                    let lookUps = try snapshot?.documents.compactMap { doc in
                        var item = try doc.data(as: LookupItem.self)
                        item.id = doc.documentID
                        return item
                    }
                    completion(lookUps, nil)
                    
                } catch {
                    print("\(error)")
                    completion(nil, ServiceError.unknownError)
                }
            }
    }
}

