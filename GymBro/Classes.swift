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
}
