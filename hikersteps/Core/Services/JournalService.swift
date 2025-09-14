//
//  journalService.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 01/07/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol JournalServiceProtocol {
    
    /**
     Update the statistics for the Journal. If there are no statistics for the Journal, they will be added, otherwise merged with the statistics that exist.
     
     - Parameters:
        - journalId: id of the Journal
        - statistics: a ``JournalStatistics`` value
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func updateStatistics(journalId: String, statistics: JournalStatistics) async throws
    
    /**
     Updates the Journal with a url of the image to be presented in the app for the Journal.
     
     - Throws:
        - `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func updateHeroImage(journalId: String, urlString: String) async throws
    
    /**
     Returns all Journals that are associated with the logged in user. If the user is not logged in, the func returns an empty array.
     */
    func getJournals() async throws -> [Journal]
    
    /**
     Retrieves a Journal. If no document exists with the given id the method returns nil.
     */
    func getJournal(id: String) async throws -> Journal?
    
    /**
     Get's the journal marked as current. If no journal is marked as current then the most recent one is display.
     */
    func getCurrentJournal() async throws -> Journal?
    
    /**
     Save the Journal to firestore. If it exists it's updated, otherwise a new Journal document is created.
     
     - Parameters:
        - journal: Journal record to be updated.
     
     - Throws: `ServiceError.unauthenticatedUser` if the caller is not authenticated
     
     */
    func updateJournal (journal: Journal) async throws
    
    /**
     Adds a new Journal to firestore
     
     - Returns: the id of the new Journal
     - Parameters:
        - journal: represents the ``Journal`` to add
     - Throws: a `ServiceError.unauthenticatedUser` if the caller is not authenticated
     */
    func addJournal(journal: Journal) async throws -> String
    
    /**
     Deletes a Journal AND all it's associated CheckIns and Storage images.
     
     - Parameters:
        - journal: Journal to be deleted
        - cascade: Default is true, which also deletes associated CheckIns and Images.
     
     - Important: If cascade is false, then only the Journal document is deleted, regardless of whether it has any CheckIns. This could leave orphaned CheckIns and is only supported for testing purposes.
     
     When cascade is set to true (the default), the delete action is a two step process
     - First the CheckIn images in Storage are deleted. We can't batch this and just do our best!
     - We then batch all of the Journal's CheckIns and the Journal document itself into a batch delete operation

     - Throws: a `ServiceError.unauthenticatedUser` if the caller is not authenticated
     
     */
    func deleteJournal (journal: Journal, cascade: Bool) async throws
}

/**
 The Journal service enabled create/update/delete operations on a Journal entity.
 
 - Important: Within Firestore a Journal is recorded within the `adventures` collection for historic reasons.
 */
class JournalService: JournalServiceProtocol {
    let db = Firestore.firestore()
    
    func getCurrentJournal() async throws -> Journal? {
        let journals = try await getJournals()
        
        return journals.sorted(by: { $0.startDate > $1.startDate }).first
    }
    
    func getJournal(id: String) async throws -> Journal? {
        let docRef = db.collection(FirestoreCollection.journals).document(id)
        do {
            let snapshot = try await docRef.getDocument()
            if snapshot.exists {
                var item = try snapshot.data(as: Journal.self)
                item.id = snapshot.documentID
                return item
            } else {
                return nil
            }
        } catch {
            // this usually means you're ready a document that doesn't exist (usually only happens in testing)
            return nil
        }
    }
    
    func updateHeroImage(journalId: String, urlString: String) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let docRef = db.collection(FirestoreCollection.journals).document(journalId)
        try await docRef.setData([Journal.CodingKeys.heroImageUrl.rawValue: urlString], merge: true)
    }
    
    func updateStatistics(journalId: String, statistics: JournalStatistics) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        
        let docRef = db.collection(FirestoreCollection.journals).document(journalId)
        
        try await docRef.setData ([Journal.CodingKeys.statistics.rawValue: statistics.toDictionary()], merge: true)
    }
    
    func getJournals() async throws -> [Journal] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let snapshot = try await db.collection(FirestoreCollection.journals)
            .whereField("uid", isEqualTo: uid)
            .getDocuments()
        
        let journals = try snapshot.documents.compactMap { doc -> Journal? in
            var item = try doc.data(as: Journal.self)
            item.id = doc.documentID
            return item
        }
        return journals
    }

    func addJournal(journal: Journal) async throws -> String {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        let docRef = db.collection(FirestoreCollection.journals).document()
        try await docRef.setData(journal.toDictionary())
        return docRef.documentID
    }
    
    func updateJournal (journal: Journal) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard let id = journal.id else { throw ServiceError.missingField("id") }
        
        try await db.collection(FirestoreCollection.journals)
            .document(id)
            .setData(journal.toDictionary(), merge: true)
    }
    
    func deleteJournal (journal: Journal, cascade: Bool = true) async throws {
        guard let _ = Auth.auth().currentUser else { throw ServiceError.unauthenticatedUser }
        guard let id = journal.id else { throw ServiceError.missingField("Journal id") }

        let batch = db.batch()
        
        if cascade {
            let checkInService = CheckInService()
            
            // delete all the images across all checkins (we can't do these in the batch)
            let checkIns = try await checkInService.getCheckIns(uid: journal.uid, journalId: id)
            for checkIn in checkIns {
                try await checkInService.deleteAllImages(from: checkIn)
            }
            
            // add the journals's checkin deletes to the batch
            try await checkInService.addCheckInDeletes(to: batch, for: journal)
        }
        
        // Delete the journal itself
        let docRef = db.collection(FirestoreCollection.journals).document(id)
        batch.deleteDocument(docRef)
        
        try await batch.commit()
    }
}

extension JournalService {
    class Mock: JournalServiceProtocol {
        
        init(newUser: Bool = false) {
            self.newUser = newUser
        }
        
        var newUser: Bool = false
        
        func getCurrentJournal() async throws -> Journal? {
            return nil
        }
        
        func updateJournal(journal: Journal) async throws {
            //
        }
        
        func addJournal(journal: Journal) async throws -> String {
            return ""
        }
        
        func getJournal(id: String) async throws -> Journal? {
            return Journal.sample
        }
        
        func updateHeroImage(journalId: String, urlString: String) async throws {
            return
        }
        
        func updateStatistics(journalId: String, statistics: JournalStatistics) async throws {
            return
        }
        
        func getJournals() async throws -> [Journal] {
            if newUser {
                return []
            } else {
                var journal = Journal(uid: "abc", name: "Tokes on the TA")
                journal.uid = "abc"
                journal.id = "1"
                journal.description = "Let's do this!"
                journal.statistics = JournalStatistics.sample
                return [journal, Journal.sample]
            }
        }
        
        func deleteJournal (journal: Journal, cascade: Bool) async throws {
            // do nothing
        }
    }
}
