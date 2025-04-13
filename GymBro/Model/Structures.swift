//
//  ChatUser.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import Foundation
import FirebaseFirestore

struct ChatUser: Identifiable, Equatable {
    var id: String { uid }
    let uid: String
    var email, username, bio, gender, age, weight, height: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.weight = data["weight"] as? String ?? ""
        self.height = data["height"] as? String ?? ""
    }
}

struct Message: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromId, toId, text: String
    let received: Bool
    let timestamp: Date
    let isWorkout: Bool
    let workoutId: String
}

struct ExistingChats: Identifiable {
    var id: String { documentID }
    
    let documentID: String
    let text, email: String
    let fromId, toId: String
    let timestamp: Date
    let username: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentID = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.username = data["username"] as? String ?? ""
    }
}

struct Workout: Identifiable, Codable, Equatable {
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

struct WorkoutDone: Identifiable, Codable, Equatable {
    let id: String
    
    let workout: Workout
    let timestamp: Date
    let comment: String
}

struct CalendarDate: Identifiable {
    let id = UUID()
    var day: Int
    var date: Date
    
    var workouts: [WorkoutDone] = []
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self.date, inSameDayAs: other)
    }
}
