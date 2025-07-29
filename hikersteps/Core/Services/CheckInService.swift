//
//  CheckInService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 03/07/2025.
//

import Foundation

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CheckInService {
    
    enum ServiceError: Error {
        case unknownError
    }
    
    static func getCheckIns(uid: String, adventureId: String, completion: @escaping ([CheckIn]?, Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("check-ins")
            .whereField("uid", isEqualTo: uid)
            .whereField("adventureId", isEqualTo: adventureId)
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                do {
                    let checkins = try snapshot?.documents.compactMap { doc in
                        var item = try doc.data(as: CheckIn.self)
                        item.id = doc.documentID
                        return item
                    }
                    completion(checkins, nil)
                    
                } catch {
                    print("\(error)")
                    completion(nil, ServiceError.unknownError)
                }
            }
    }
}
