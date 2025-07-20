//
//  TrailService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation

struct TrailService {
    
    /**
     Return an array of available trails.
     */
    static func fetchTrails(completion: @escaping ([Trail]?, Error?) -> Void) {
        let trails = [
            Trail(id: "TA", name: "Te Araroa"),
            Trail(id: "BB", name: "Bibbulmun Trail"),
        ]
        completion(trails, nil)
    }
}
