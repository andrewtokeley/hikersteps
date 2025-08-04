//
//  FirestoreEncodable.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/08/2025.
//

import Foundation
import FirebaseFirestore

protocol FirestoreEncodable: Encodable {
    func toDictionary() throws -> [String: Any]
}

extension FirestoreEncodable {
    func toDictionary() throws -> [String: Any] {
        let encoder = Firestore.Encoder()
        return try encoder.encode(self)
    }
}

