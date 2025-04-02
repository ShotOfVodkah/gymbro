//
//  ChatUser.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import Foundation

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
