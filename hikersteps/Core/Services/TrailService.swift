//
//  TrailService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/07/2025.
//

import Foundation
import FirebaseFirestore

protocol TrailServiceProtocol {
    
    /**
     Returns all trails in the system
     */
    func getTrails() async throws -> [Trail]
}

class TrailService: TrailServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "trails"

    // Temporary way to get the trails into firestore - this list is the master list and can be set by admin from settings.
    static let allTrails: [Trail] = [
        Trail(
            key: "AT",
            name: "Appalachian Trail",
            country: "USA",
            countryCode: "US",
            length: DistanceUnit(3537, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 45.909, longitude: -68.109), title: "Mount Katahdin, Maine"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 34.990, longitude: -83.492), title: "Springer Mountain, Georgia")
            ]
        ),
        Trail(
            key: "PCT",
            name: "Pacific Crest Trail",
            country: "USA",
            countryCode: "US",
            length: DistanceUnit(4265, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 49.000, longitude: -120.000), title: "Canada - US Border"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 32.645, longitude: -116.466), title: "Mexico - US Border")
            ]
        ),
        Trail(
            key: "CDT",
            name: "Continental Divide Trail",
            country: "USA",
            countryCode: "US",
            length: DistanceUnit(4418, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 49.000, longitude: -104.000), title: "Waterton Lakes NP, Alberta"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 32.000, longitude: -108.000), title: "Crazy Cook Monument, New Mexico")
            ]
        ),
        Trail(
            key: "TA",
            name: "Te Araroa",
            country: "New Zealand",
            countryCode: "NZ",
            length: DistanceUnit(3000, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: -45.000, longitude: 170.000), title: "Cape Reinga"),
                CheckInAnnotation(coordinate: Coordinate(latitude: -34.000, longitude: 172.000), title: "Bluff, Sterling Point")
            ]
        ),
        Trail(
            key: "SI",
            name: "Sentiero Italia",
            country: "Italy",
            countryCode: "IT",
            length: DistanceUnit(6000, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 47.000, longitude: 10.000), title: "San Bartolomeo near Trieste"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 36.000, longitude: 14.000), title: "Santa Teresa Gallura")
            ]
        ),
        Trail(
            key: "INT",
            name: "Israel National Trail",
            country: "Israel",
            countryCode: "IS",
            length: DistanceUnit(1013, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 33.000, longitude: 35.000), title: "Kibbutz Dan"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 29.500, longitude: 34.750), title: "Eilat")
            ]
        ),
        Trail(
            key: "SWCP",
            name: "South West Coast Path",
            country: "United Kingdom",
            countryCode: "GB",
            length: DistanceUnit(1014, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 51.210, longitude: -4.116), title: "Minehead, Somerset"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 50.717, longitude: -1.978), title: "Poole Harbour, Dorset")
            ]
        ),
        Trail(
            key: "GDT",
            name: "Great Divide Trail",
            country: "Canada",
            countryCode: "CA",
            length: DistanceUnit(1113, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 60.000, longitude: -114.000), title: "Waterton Lake, Alberta"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 49.000, longitude: -114.000), title: "Kakwa Lake, Kakwa Provincial Park, British Columbia")
            ]
        ),
        Trail(
            key: "HEX",
            name: "HexaTrek",
            country: "France",
            countryCode: "FR",
            length: DistanceUnit(3034, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: 48.960, longitude: 7.435), title: "Wissembourg, Alsace"),
                CheckInAnnotation(coordinate: Coordinate(latitude: 43.370, longitude: -1.780), title: "Hendaye, French Basque Country")
            ]
        ),
        Trail(
            key: "BIB",
            name: "Bibbulmun Track",
            country: "Australia",
            countryCode: "AU",
            length: DistanceUnit(1004, .km),
            startLocations: [
                CheckInAnnotation(coordinate: Coordinate(latitude: -31.980, longitude: 116.070), title: "Kalamunda"),
                CheckInAnnotation(coordinate: Coordinate(latitude: -35.020, longitude: 117.880), title: "Albany")
            ]
        )
    ]
    
    func addDefaults() async throws {
        try await addOrUpdateTrails(TrailService.allTrails)
    }
    
    func addOrUpdateTrails(_ trails: [Trail]) async throws {
        let batch = db.batch()
        
        for trail in trails {
            let docRef = db.collection(collection).document(trail.id)
            if let dict = try? trail.toDictionary() {
                batch.setData(dict, forDocument: docRef, merge: true)
            }
        }
        
        try await batch.commit()
    }
    
    func getTrails() async throws -> [Trail] {
        let snapshot = try await db.collection(collection)
            .getDocuments()
        do {
            let trails = try snapshot.documents.compactMap { doc -> Trail? in
                var item = try doc.data(as: Trail.self)
                item.key = doc.documentID
                return item
            }
            return trails
        } catch {
            throw error
        }
    }
}

extension TrailService {
    
    class Mock: TrailServiceProtocol {
        func getTrails() async throws -> [Trail] {
            return TrailService.allTrails
        }
    }
    
}
