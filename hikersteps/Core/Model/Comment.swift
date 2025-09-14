//
//  Comment.swift
//  hikersteps
//
//  Created by Andrew Tokeley on 02/09/2025.
//

import Foundation


/**
 A comment about a journal or entry (source)
 */
struct Comment: Identifiable, Codable, FirestoreEncodable {
    var id: String = ""
    private var _source: String = "none"
    var source: SourceType {
        get {
            return SourceType(rawValue: _source) ?? .none
        }
        set {
            _source = newValue.rawValue
        }
    }
    var sourceId: String
    var uid: String
    var username: String
    private var profileUrlString: String
    var profileUrl: URL? {
        get {
            URL(string: profileUrlString)
        }
        set {
            profileUrlString = newValue?.absoluteString ?? ""
        }
    }
    var comment: String
    var createdDate: Date
    var reactionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case _source = "source"
        case sourceId
        case uid
        case username
        case profileUrlString
        case comment
        case createdDate
        case reactionCount
    }
    
    /**
     Main initialiser to create a new Comment. Date will default to `Date()
     
     Only supply an id if required for testing`
     */
    init(id: String = "", uid: String, source: SourceType, sourceId: String, username: String, profileUrlString: String, comment: String, reactionCount: Int = 0) {
        self.id = id
        self.reactionCount = reactionCount
        self.sourceId = sourceId
        self.comment = comment
        self.uid = uid
        self.username = username
        self.createdDate = Date()
        self.profileUrlString = profileUrlString
        self.source = source
    }
    
    /**
     Initiaiser used by firestore to rehydrate struct
     */
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._source = try container.decodeIfPresent(String.self, forKey: ._source) ?? "none"
        self.sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId) ?? ""
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? ""
        self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment) ?? ""
        self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
        self.profileUrlString = try container.decodeIfPresent(String.self, forKey: .profileUrlString) ?? ""
        self.reactionCount = try container.decodeIfPresent(Int.self, forKey: .reactionCount) ?? 0
    }
    
    static var nilValue: Comment {
        return Comment(uid: "", source: .none, sourceId: "", username: "", profileUrlString: "", comment: "")
    }
    var isNil: Bool {
        return self.uid == ""
    }
}
