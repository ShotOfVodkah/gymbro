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
    var reactions: [String]
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

struct Streak: Identifiable, Equatable {
    var id: String { uid }
    let uid: String
    
    var currentStreak, numberOfWorkoutsAWeek: Int
    var lastCheckData: Date
    var lastCheckWeek: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.currentStreak = data["currentStreak"] as? Int ?? 0
        self.numberOfWorkoutsAWeek = data["numberOfWorkoutsAWeek"] as? Int ?? 1
        self.lastCheckData = (data["lastCheckData"] as? Timestamp)?.dateValue() ?? Date()
        self.lastCheckWeek = data["lastCheckWeek"] as? String ?? ""
    }
}

struct UserRanking: Identifiable {
    var id: String
    var username: String
    var isFriend: Bool
    var totalWorkouts: Int
    var currentStreak: Int
}

struct Achievement {
    var achievementName: String
    var description: String
    var iconName: String
    var achievementCompleted: Bool
}

struct Teams: Identifiable {
    let id: String
    let team_name: String
    let owner: String
    let members: [String]
    let created_at: Date
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.team_name = data["team_name"] as? String ?? ""
        self.owner = data["owner"] as? String ?? ""
        self.members = data["members"] as? [String] ?? []
        self.created_at = (data["created_at"] as? Timestamp)?.dateValue() ?? Date()
    }
}

struct Challenge: Identifiable {
    let id: String
    let start_date: Date
    let end_date: Date
    let muscle_group: String
    let challenge_name: String
    let goal_type: String
    let exercise_id: String
    let goal_amount: Int
    let description: String
    var teams_participating: [String]
    
    init(data: [String: Any]) {
        self.id = data["id"] as? String ?? ""
        self.start_date = (data["start_date"] as? Timestamp)?.dateValue() ?? Date()
        self.end_date = (data["end_date"] as? Timestamp)?.dateValue() ?? Date()
        self.muscle_group = data["muscle_group"] as? String ?? ""
        self.challenge_name = data["challenge_name"] as? String ?? ""
        self.exercise_id = data["exercise_id"] as? String ?? ""
        self.goal_type = data["goal_type"] as? String ?? ""
        self.goal_amount = data["goal_amount"] as? Int ?? 0
        self.description = data["description"] as? String ?? ""
        self.teams_participating = data["teams_participating"] as? [String] ?? []
    }
}

struct ProgressChallenges: Identifiable {
    var id: String { challenge_id }
    
    let challenge_id: String
    let team_id: String
    let exercise_id: String
    let start_date: Date
    let end_date: Date
    var progress_per_member: [String: Int]
    var total_progress: Int
    var status: Int
    
    init(data: [String: Any]) {
        self.challenge_id = data["challenge_id"] as? String ?? ""
        self.team_id = data["team_id"] as? String ?? ""
        self.exercise_id = data["exercise_id"] as? String ?? ""
        self.start_date = (data["start_date"] as? Timestamp)?.dateValue() ?? Date()
        self.end_date = (data["end_date"] as? Timestamp)?.dateValue() ?? Date()
        self.progress_per_member = data["progress_per_member"] as? [String: Int] ?? [:]
        self.total_progress = data["total_progress"] as? Int ?? 0
        self.status = data["status"] as? Int ?? 0
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
    let week: String
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

struct UserStats: Codable {
    var totalWorkoutsDone: Int
    var totalExercisesDone: Int
    var totalWeightLifted: Int
    var topMuscleGroups: [String]
    var muscleGroupsCounter: [String: Int]
    var workoutsPerWeek: [String: Int]
    var bestWeek: String
}
