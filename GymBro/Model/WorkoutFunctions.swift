//
//  FireBaseFunctions.swift
//  GymBro
//
//  Created by Stepan Polyakov on 01.02.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import Firebase

func createWorkout(name: String, exercises: [Exercise], icon: String) {
    let db = Firestore.firestore()
    let docRef = db.collection("workouts").document()
    let newWorkout = Workout(id: docRef.documentID,
                             icon: icon,
                             name: name,
                             user_id: "1",
                             exercises: exercises)
    
    let workoutData: [String: Any] = [
        "id": newWorkout.id,
        "name": newWorkout.name,
        "user_id": newWorkout.user_id,
        "icon": newWorkout.icon,
        "exercises": exercises.map { exercise in
            return [
                "name": exercise.name,
                "muscle_group": exercise.muscle_group,
                "is_selected": exercise.is_selected,
                "weight": exercise.weight,
                "sets": exercise.sets,
                "reps": exercise.reps
            ]
        }
    ]
    
    docRef.setData(workoutData) { error in
        if let error = error {
            print("Ошибка: \(error.localizedDescription)")
        } else {
            print("\(docRef.documentID)")
        }
    }
}

func deleteWorkout(id: String) {
    let db = Firestore.firestore()
    db.collection("workouts").document(id).delete { error in
        if let error = error {
            print("Ошибка: \(error.localizedDescription)")
        } else {
            print("Удалено")
        }
    }
}

func saveWorkoutDone(workout: Workout, comment: String) {
    let db = Firestore.firestore()
    let docRef = db.collection("workout_done").document()
    
    let workoutDone = WorkoutDone(
        id: docRef.documentID,
        workout: workout,
        timestamp: Date(),
        comment: comment
    )
    
    let workoutDoneData: [String: Any] = [
        "id": workoutDone.id,
        "workout": [
            "id": workout.id,
            "name": workout.name,
            "user_id": workout.user_id,
            "icon": workout.icon,
            "exercises": workout.exercises.map { exercise in
                return [
                    "name": exercise.name,
                    "muscle_group": exercise.muscle_group,
                    "is_selected": exercise.is_selected,
                    "weight": exercise.weight,
                    "sets": exercise.sets,
                    "reps": exercise.reps
                ]
            }
        ],
        "timestamp": Timestamp(date: workoutDone.timestamp),
        "comment": workoutDone.comment
    ]
    
    docRef.setData(workoutDoneData) { error in
        if let error = error {
            print("Ошибка: \(error.localizedDescription)")
        } else {
            print("\(docRef.documentID)")
        }
    }
}
