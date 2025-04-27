//
//  StatisticsModel.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.04.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class StatisticsViewModel: ObservableObject {
    @Published var userMap: [String: String]
    @Published var userStats: UserStats?

    init(userMap: [String: String]) {
        self.userMap = userMap
        fetchStats()
    }
    
    func fetchStats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let statsRef = Firestore.firestore().collection("user_stats").document(uid)
        
        statsRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let data = snapshot?.data(), let existingStats = try? Firestore.Decoder().decode(UserStats.self, from: data) {
                self.userStats = existingStats
            } else {
                let defaultStats = UserStats(
                    totalWorkoutsDone: 0,
                    totalExercisesDone: 0,
                    totalWeightLifted: 0,
                    topMuscleGroups: [],
                    muscleGroupsCounter: [:],
                    workoutsPerWeek: [:],
                    bestWeek: ""
                )
                self.userStats = defaultStats
            }
        }
    }
}

func updateUserStats(workoutDone: WorkoutDone, userId: String) {
    let statsRef = Firestore.firestore().collection("user_stats").document(userId)
    statsRef.getDocument { snapshot, error in
        var stats: UserStats
        if let data = snapshot?.data(), let existingStats = try? Firestore.Decoder().decode(UserStats.self, from: data) {
            stats = existingStats
        } else {
            stats = UserStats(
                totalWorkoutsDone: 0,
                totalExercisesDone: 0,
                totalWeightLifted: 0,
                topMuscleGroups: [],
                muscleGroupsCounter: [:],
                workoutsPerWeek: [:],
                bestWeek: ""
            )
        }
        stats.totalWorkoutsDone += 1
        stats.totalExercisesDone += workoutDone.workout.exercises.count
        for exercise in workoutDone.workout.exercises {
            stats.totalWeightLifted += exercise.weight * exercise.reps * exercise.sets
            stats.muscleGroupsCounter[exercise.muscle_group, default: 0] += 1
        }
        let sortedGroups = stats.muscleGroupsCounter.sorted { $0.value > $1.value }
        stats.topMuscleGroups = Array(sortedGroups.prefix(3).map { $0.key })
        let currentWeek = workoutDone.week
        stats.workoutsPerWeek[currentWeek, default: 0] += 1
        if let best = stats.workoutsPerWeek.max(by: { $0.value < $1.value }) {
            stats.bestWeek = best.key
        }
        do {
            let data = try Firestore.Encoder().encode(stats)
            statsRef.setData(data) { error in
                if let error = error {
                    print("Failed to update user stats: \(error.localizedDescription)")
                } else {
                    print("User stats successfully updated.")
                }
            }
        } catch {
            print("Failed to encode user stats: \(error.localizedDescription)")
        }
    }
}
