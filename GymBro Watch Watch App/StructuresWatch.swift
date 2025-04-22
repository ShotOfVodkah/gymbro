//
//  StructuresWatch.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 08.04.2025.
//

import Foundation

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

struct WorkoutDone: Identifiable, Codable {
    let id: String
    
    let workout: Workout
    let timestamp: Date
    let comment: String
    let week: String
}
