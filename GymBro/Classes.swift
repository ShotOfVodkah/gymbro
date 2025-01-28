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

struct Exercise: Identifiable, Codable {
    let id = UUID()
    
    let name: String
    let muscle_group: String
    let is_selected: Bool
    let weight: Int
    let sets: Int
    let reps: Int
}

struct User: Identifiable, Codable {
    let id = UUID()
    
    let user_id: String
    let name: String
    let friends: [UUID]
    let feeds: [UUID]
}

