//
//  ChatUser.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import Foundation

struct ChatUser {
    let uid, email: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
    }
}

