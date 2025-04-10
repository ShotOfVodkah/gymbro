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
import FirebaseAuth

func createWorkout(name: String, exercises: [Exercise], icon: String) {
    let db = Firestore.firestore()
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let docRef = db.collection("workouts").document(uid).collection("workouts_for_id").document()
    let newWorkout = Workout(id: docRef.documentID,
                             icon: icon,
                             name: name,
                             user_id: "1",
                             exercises: exercises)
    
    let workoutData: [String: Any] = [
        "id": newWorkout.id,
        "name": newWorkout.name,
        "user_id": uid,
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
    guard let uid = Auth.auth().currentUser?.uid else { return }
    db.collection("workouts").document(uid).collection("workouts_for_id").document(id).delete { error in
        if let error = error {
            print("Ошибка: \(error.localizedDescription)")
        } else {
            print("Удалено")
        }
    }
}

func saveWorkoutDone(workout: Workout, comment: String) {
    let db = Firestore.firestore()
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let docRef = db.collection("workout_done").document(uid).collection("workouts_for_id").document()
    
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
            "user_id": uid,
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

class WorkoutHistoryModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var doneWorkouts = [WorkoutDone]()
    
    init() {
        fetchDoneWOs()
    }

    private func fetchDoneWOs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.doneWorkouts.removeAll()
        Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").order(by: "timestamp", descending: true).getDocuments { documentSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch done workouts: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            
            documentSnapshot?.documents.forEach { document in
                do {
                    let workoutDone = try document.data(as: WorkoutDone.self)
                    self.doneWorkouts.append(workoutDone)
                } catch {
                    self.errorMessage = "Error decoding document \(document.documentID): \(error.localizedDescription)"
                    print(self.errorMessage)
                }
            }
        }
    }
}
