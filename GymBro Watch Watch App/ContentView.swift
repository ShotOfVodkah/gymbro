//
//  ContentView.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 08.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = WatchDataManager.shared
        
    var body: some View {
        List {
            Section("User: \(dataManager.currentUID)") {
                ForEach(dataManager.workouts) { workout in
                    VStack(alignment: .leading) {
                        Text(workout.name)
                        Text("Exercises: \(workout.exercises.count)")
                                .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("My Workouts")
    }
}

#Preview {
    ContentView()
}
