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
            if self.doneWorkouts.count == 1 {
                markAchievementAsCompleted(achievementID: "0vMMc8iknhSosB9wcmXM")
            } else if self.doneWorkouts.count == 50 {
                markAchievementAsCompleted(achievementID: "1MjxVnunChWgly7VKtkM")
            } else if self.doneWorkouts.count == 100 {
                markAchievementAsCompleted(achievementID: "4cENHmNLAs1Cr5A9jykt")
            } else if self.doneWorkouts.count == 200 {
                markAchievementAsCompleted(achievementID: "99BGNHMDfivliAgiFPq0")
            } else if self.doneWorkouts.count == 300 {
                markAchievementAsCompleted(achievementID: "BSkSsaqaAHcjZsD1d2kj")
            } else if self.doneWorkouts.count == 400 {
                markAchievementAsCompleted(achievementID: "C6jwV9VIDwewhTMeMmKQ")
            } else if self.doneWorkouts.count == 500 {
                markAchievementAsCompleted(achievementID: "FYgq3jCjunGFCPEWPtI2")
            }
        }
    }
}
