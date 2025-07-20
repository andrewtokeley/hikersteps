//
//  HikeService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct HikerService {
    
    enum HikerServiceError: Error {
        case unauthenticateUser
        case unknownError
    }
    
    static func fetchHikes(completion: @escaping ([Hike]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        if let uid = Auth.auth().currentUser?.uid {
            
            db.collection("adventures")
                .whereField("uid", isEqualTo: uid)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    do {
                        let hikes = try snapshot?.documents.compactMap { doc in
                            return try doc.data(as: Hike.self)
                        }
                        completion(hikes, nil)

                    } catch {
                        completion(nil, HikerServiceError.unknownError)
                    }
                }
        } else {
            completion(nil, HikerServiceError.unauthenticateUser)
        }
    }
}
