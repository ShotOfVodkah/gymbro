//
//  ChatUser.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import Foundation
import FirebaseFirestore

struct ChatUser: Identifiable {
    var id: String { uid }
    let uid, email: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}

struct Message: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromId, toId, text: String
    let received: Bool
    let timestamp: Date
}

struct ExistingChats: Identifiable {
    var id: String { documentID }
    
    let documentID: String
    let text, email: String
    let fromId, toId: String
    let timestamp: Date
    
    init(documentId: String, data: [String: Any]) {
        self.documentID = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }
}

struct Workout: Identifiable, Codable {
    let id: String
    let icon: String
    let name: String
    let user_id: String
    var exercises: [Exercise]
}

struct Exercise: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    
    var name: String
    var muscle_group: String
    var is_selected: Bool
    var weight: Int
    var sets: Int
    var reps: Int
}

struct User: Identifiable, Codable {
    let id = UUID()
    
    let user_id: String
    let name: String
    let friends: [UUID]
    let feeds: [UUID]
}
