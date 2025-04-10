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
    
    sendWorkoutToAllFriends(woId: workoutDone.id)
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


func sendWorkoutToAllFriends(woId: String) { // поменять когда появятся друзья
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    
    Firestore.firestore().collection("usersusers").getDocuments { documentsSnapshot, error in
        if let error = error {
            print("Failed to fetch users: \(error.localizedDescription)")
            return
        }
        documentsSnapshot?.documents.forEach { snapshot in
            let data = snapshot.data()
            let user = ChatUser(data: data)
            if user.uid != fromId {
                
                let messageData = ["fromId": fromId, "toId": user.uid, "text": "New workout added", "timestamp": Date(), "received": false, "isWorkout": true, "workoutId": woId] as [String : Any]
                Firestore.firestore().collection("messages").document(fromId).collection(user.uid).document().setData(messageData) { error in
                    if let error = error {
                        print("Failed to save workout message cause \(error.localizedDescription)")
                        return
                    }
                    print("Successfully sent workout message")
                    
                    let data = ["timestamp": Date(), "text": "New workout added", "fromId": fromId, "toId": user.uid, "email": user.email, "username": user.username, "isWorkout": true, "workoutId": woId] as [String : Any]
                    Firestore.firestore().collection("existing_chats").document(fromId).collection("messages").document(user.uid).setData(data) { error in
                        if let error = error {
                            print("Failed to save chat document: \(error.localizedDescription)")
                            return
                        }
                        print("Successfully saved chat document")
                    }
                    
                    Firestore.firestore().collection("usersusers").document(fromId).getDocument { documentSnapshot, error in
                        if let error = error {
                            print("Failed to fetch user: \(error.localizedDescription)")
                            return
                        }
                        guard let document = documentSnapshot, document.exists, let data = document.data() else {
                            print("User document does not exist")
                            return
                        }
                        let currentUser = ChatUser(data: data)
                        let recipientData = ["timestamp": Date(), "text": "New workout added", "fromId": fromId, "toId": user.uid, "email": currentUser.email, "username": currentUser.username, "isWorkout": true, "workoutId": woId] as [String : Any]
                        Firestore.firestore().collection("existing_chats").document(user.uid).collection("messages").document(fromId).setData(recipientData) { error in
                            if let error = error {
                                print("Failed to save chat document: \(error.localizedDescription)")
                                return
                            }
                            print("Successfully saved recipient chat document")
                        }
                    }
                }
                
                let recipientmessageData = ["fromId": fromId, "toId": user.uid, "text": "New workout added", "timestamp": Date(), "received": true, "isWorkout": true, "workoutId": woId] as [String : Any]
                Firestore.firestore().collection("messages").document(user.uid).collection(fromId).document().setData(recipientmessageData) { error in
                    if let error = error {
                        print("Failed to save workout message cause \(error.localizedDescription)")
                        return
                    }
                }
                print("Successfully received workout message")
            }
        }
    }
}
