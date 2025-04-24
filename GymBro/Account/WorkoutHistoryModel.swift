//
//  WorkoutHistoryModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
