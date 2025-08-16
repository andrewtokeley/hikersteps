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
import CoreLocation

protocol CheckInServiceProtocol {
    func getCheckIns(uid: String, adventureId: String) async throws -> [CheckIn]
    
    /**
     Updates the checkin. If it doesn't exist it will add a new checkin
     
     - Returns: The id of the checkIn as a `String`. This is useful if saving a new checkIn.
     */
    func updateCheckIn (checkIn: CheckIn) async throws -> String
    
    func save(manager: CheckInManager) async throws
}

class CheckInService: CheckInServiceProtocol {
    
    func save(manager: CheckInManager) async throws {
    
        let changes = manager.changes
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Add new CheckIns
        for checkIn in changes.added {
            let newDocRef = db.collection("checkins").document()
            if let dictionary = try? checkIn.toDictionary() {
                batch.setData(dictionary, forDocument: newDocRef)
            }
        }
        
        // Update existing CheckIns
        for checkIn in changes.modified {
            guard let id = checkIn.id else { continue }
            let docRef = db.collection("checkIns").document(id)
            if let dictionary = try? checkIn.toDictionary() {
                batch.setData(dictionary, forDocument: docRef, merge: true)
            }
        }
        
        // Delete CheckIns
        for checkIn in changes.removed {
            guard let id = checkIn.id else { continue }
            let docRef = db.collection("checkIns").document(id)
            batch.deleteDocument(docRef)
        }
        
        // Commit the batch
        try await batch.commit()
    }
    
    func getCheckIns(uid: String, adventureId: String) async throws -> [CheckIn] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("check-ins")
            .whereField("uid", isEqualTo: uid)
            .whereField("adventureId", isEqualTo: adventureId)
            .order(by: "date", descending: false)
            .getDocuments()
        
        do {
            let checkins = try snapshot.documents.compactMap { doc -> CheckIn? in
                var item = try doc.data(as: CheckIn.self)
                item.id = doc.documentID
                return item
            }
            return checkins
        } catch {
            throw ServiceError.unknownError
        }
    }
    
    func updateCheckIn (checkIn: CheckIn) async throws -> String {
        let db = Firestore.firestore()
        var id: String
        
        if let _ = checkIn.id {
            id = checkIn.id!
        } else {
            let docRef = db.collection("check-ins").document() // generates a new ID
            id = docRef.documentID
        }
        
        do {
            try await db.collection("check-ins")
                    .document(id)
                    .setData(checkIn.toDictionary(), merge: true)
            
            return id
            
        } catch {
            throw error
        }
    }
}

class CheckInServiceMock: CheckInServiceProtocol {
    func getCheckIns(uid: String, adventureId: String) async throws -> [CheckIn] {
        return [
            CheckIn(id: "4", uid: "123", location: Coordinate(latitude: -41.12, longitude: 174.7787), title: "Cap Reinga", notes: "Hello there, great spot Hello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spotHello there, great spot", distance: DistanceUnit(10, .km), date: Date(), images: [StorageImage.sample]),
            CheckIn(id: "0", uid: "xxx", location: Coordinate(latitude: -41.16, longitude: 174.7787), title: "Twolight Campsite", notes: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam",  distance: DistanceUnit(21, .km), date: Date(), accommodation: LookupItem(id: "1", name: "Tent", imageName: "tent")),
            CheckIn(id: "1", uid: "xxx", location: Coordinate(latitude: -41.19, longitude: 174.7787), title: "Brakenexk Speed Camp",  distance: DistanceUnit(35, .km), numberOfRestDays: 2, date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
            CheckIn(id: "2",  uid: "xxx", location: Coordinate(latitude: -41.29, longitude: 174.7787), title: "Wild Camping", distance: DistanceUnit(42, .km), date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!),
            CheckIn(id: "3", uid: "xxx", location: Coordinate(latitude: -41.39, longitude: 174.7787), title: "Cherokee Point Camp",  distance: DistanceUnit(15, .km), date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
        ]
    }
    
    func updateCheckIn(checkIn: CheckIn) async throws -> String {
        // do nothing
        return ""
    }
    
    func save(manager: CheckInManager) async throws {
        // do nothing
        return
    }
    
}


