//
//  Classes.swift
//  GymBro
//
//  Created by Stepan Polyakov on 23.01.2025.
//
import SwiftUI

struct Workout: Identifiable, Decodable {
    let id = UUID()
    
    let icon: String
    let name: String
    let user_id: String
    let exercises: [UUID]
}

struct Ex_detail: Identifiable, Decodable {
    let id = UUID()
    
    let ex_id: UUID
    let weight: Int
    let sets: Int
    let reps: Int
}

struct Exercise: Identifiable, Decodable {
    let id = UUID()
    
    let name: String
    let muscle_group: String
}

struct User: Identifiable, Decodable {
    let id = UUID()
    
    let user_id: String
    let name: String
    let friends: [UUID]
    let feeds: [UUID]
}

