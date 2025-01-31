//
//  Classes.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//
import SwiftUI

struct Workout: Identifiable, Codable {
    let id = UUID()
    
    let icon: String
    let name: String
    let user_id: String
    let exercises: [Exercise]
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

