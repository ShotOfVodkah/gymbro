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
import WidgetKit

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
            markAchievementAsCompleted(achievementID: "q3qlpBVNoUUv5ZlJZWDZ")
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
    UIApplication.shared.applicationIconBadgeNumber -= 1
    let db = Firestore.firestore()
    guard let uid = Auth.auth().currentUser?.uid else {
        return
    }
    
    let workoutRef = db.collection("workouts").document(uid).collection("workouts_for_id").document(workout.id)
    
    let exerciseData = workout.exercises.map { exercise in
        return [
            "name": exercise.name,
            "muscle_group": exercise.muscle_group,
            "is_selected": exercise.is_selected,
            "weight": exercise.weight,
            "sets": exercise.sets,
            "reps": exercise.reps
        ]
    }
    print(exerciseData)
    workoutRef.updateData(["exercises": exerciseData]) { error in
        if let error = error {
            print(error)
            return
        }
        let docRef = db.collection("workout_done").document(uid).collection("workouts_for_id").document()
        
        let workoutDone = WorkoutDone(
            id: docRef.documentID,
            workout: workout,
            timestamp: Date(),
            comment: comment,
            week: getCurrentWeek()
        )
        
        let workoutDoneData: [String: Any] = [
            "id": workoutDone.id,
            "workout": [
                "id": workout.id,
                "name": workout.name,
                "user_id": uid,
                "icon": workout.icon,
                "exercises": exerciseData
            ],
            "timestamp": Timestamp(date: workoutDone.timestamp),
            "comment": workoutDone.comment,
            "week": workoutDone.week
        ]
        
        docRef.setData(workoutDoneData) { error in
            if let error = error {
                print(error)
            } else {
                sendWorkoutToAllFriends(woId: workoutDone.id)
                updateUserStats(workoutDone: workoutDone, userId: uid)
                let exercises = workout.exercises.map { $0.name }
                getTeamIdForUser { teams in
                    for team_id in teams {
                        for exercise in exercises {
                            Firestore.firestore().collection("team_challenge_progress").document(team_id).collection("team_challenges").whereField("exercise_id", isEqualTo: exercise)
                                .whereField("start_date", isLessThan: Date())
                                .whereField("end_date", isGreaterThan: Date())
                                .getDocuments() { documentSnapshot, error in
                                if let error = error {
                                    print("Failed to fetch \(team_id) challenges: \(error.localizedDescription)")
                                    return
                                }
                                documentSnapshot?.documents.forEach { document in
                                    if let exercise = exerciseData.first(where: { ($0["name"] as? String) == exercise }),
                                       let reps = exercise["reps"] as? Int {
                                        Firestore.firestore().collection("team_challenge_progress").document(team_id).collection("team_challenges")
                                            .document(document.documentID)
                                            .updateData(["progress_per_member.\(uid)": FieldValue.increment(Int64(reps)),
                                                         "total_progress": FieldValue.increment(Int64(reps))]) { error in
                                            if let error = error {
                                                print("Failed to udate: \(error.localizedDescription)")
                                            } else {
                                                print("Successfully updated number of reps")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    print("all good!")
                }
                Task {
                    await saveWorkoutDatesToSharedDefaults()
                }
                let calendar = Calendar.current
                let weekday = calendar.component(.weekday, from: workoutDone.timestamp)
                let hour = calendar.component(.hour, from: workoutDone.timestamp)
                let minute = calendar.component(.minute, from: workoutDone.timestamp)
                
                if weekday == 2 {
                    markAchievementAsCompleted(achievementID: "GJgPGVZYoBRjycN4MB0M")
                } else if weekday == 7 || weekday == 1 {
                    markAchievementAsCompleted(achievementID: "WgsTaI84iZQWaYpqXcgv")
                }
                
                if 7 > hour {
                    markAchievementAsCompleted(achievementID: "Xr64eCEGlYl8cBDp3BkI")
                } else if hour > 23 {
                    markAchievementAsCompleted(achievementID: "iEmJKj9jMDliuuNz7Jo4")
                }
                
                if hour == 0 && minute == 0 {
                    markAchievementAsCompleted(achievementID: "jA68jY0RYY89lccZ4FnX")
                }
                
                if workoutDone.comment == "" {
                    markAchievementAsCompleted(achievementID: "oFncaJgd3IpLazkGkXPg")
                }
                
                let muscleGroups = workout.exercises.map { $0.muscle_group }
                if Set(muscleGroups).count >= 3 {
                    markAchievementAsCompleted(achievementID: "p5ss9ogNfe8Fev08CEll")
                }
            }
        }
    }
}

func getTeamIdForUser(completion: @escaping ([String]) -> Void) {
    guard let currentUser = Auth.auth().currentUser?.uid else {
        completion([])
        return
    }
    Firestore.firestore().collection("teams").whereField("members", arrayContains: currentUser).getDocuments { documentSnapshot, error in
        if let error = error {
            print("Failed to find user's teams: \(error.localizedDescription)")
            completion([])
            return
        }
        var result: [String] = []
        documentSnapshot?.documents.forEach { document in
            let team = Teams(data: document.data())
            result.append(team.id)
        }
        completion(result)
    }
}


func sendWorkoutToAllFriends(woId: String) {
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    
    Firestore.firestore().collection("friends").document(fromId).collection("friendsList").getDocuments { documentsSnapshot, error in
        if let error = error {
            print("Failed to fetch friends: \(error.localizedDescription)")
            return
        }
        guard let documents = documentsSnapshot?.documents, !documents.isEmpty else {
            print("No friends to send the workout to")
            return
        }

        let documentId = UUID().uuidString
        markAchievementAsCompleted(achievementID: "psv1r8cSAQOOvn2ZNCcM")
        documentsSnapshot?.documents.forEach { snapshot in
            if let uid = snapshot.data()["friend_uid"] as? String {
                let messageData = ["fromId": fromId, "toId": uid, "text": "New workout added", "timestamp": Date(), "received": false, "isWorkout": true, "workoutId": woId, "reactions": []] as [String : Any]
                Firestore.firestore().collection("messages").document(fromId).collection(uid).document(documentId).setData(messageData) { error in
                    if let error = error {
                        print("Failed to save workout message cause \(error.localizedDescription)")
                        return
                    }
                    print("Successfully sent workout message")
                    
                    Firestore.firestore().collection("usersusers").document(uid).getDocument { documentSnapshot, error in
                        if let error = error {
                            print("Failed to fetch user: \(error.localizedDescription)")
                            return
                        }
                        guard let document = documentSnapshot, document.exists, let data = document.data() else {
                            print("User document does not exist")
                            return
                        }
                        let toUser = ChatUser(data: data)
                        let senderData = ["timestamp": Date(), "text": "New workout added", "fromId": fromId, "toId": toUser.uid, "email": toUser.email, "username": toUser.username, "isWorkout": true, "workoutId": woId] as [String : Any]
                        Firestore.firestore().collection("existing_chats").document(fromId).collection("messages").document(uid).setData(senderData) { error in
                            if let error = error {
                                print("Failed to save chat document: \(error.localizedDescription)")
                                return
                            }
                            print("Successfully saved chat document")
                        }
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
                        let recipientData = ["timestamp": Date(), "text": "New workout added", "fromId": fromId, "toId": uid, "email": currentUser.email, "username": currentUser.username, "isWorkout": true, "workoutId": woId] as [String : Any]
                        Firestore.firestore().collection("existing_chats").document(uid).collection("messages").document(fromId).setData(recipientData) { error in
                            if let error = error {
                                print("Failed to save chat document: \(error.localizedDescription)")
                                return
                            }
                            print("Successfully saved recipient chat document")
                        }
                    }
                }
                
                let recipientmessageData = ["fromId": fromId, "toId": uid, "text": "New workout added", "timestamp": Date(), "received": true, "isWorkout": true, "workoutId": woId, "reactions": []] as [String : Any]
                Firestore.firestore().collection("messages").document(uid).collection(fromId).document(documentId).setData(recipientmessageData) { error in
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

func saveWorkoutDatesToSharedDefaults() async {
    guard let uid = Auth.auth().currentUser?.uid else {
        print("Пользователя нет")
        return
    }
    
    let calendar = Calendar.current
    let now = Date()

    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
          let range = calendar.range(of: .day, in: .month, for: now),
          let endOfMonth = calendar.date(byAdding: .day, value: range.count, to: startOfMonth) else {
        return
    }
    
    let startTimestamp = Timestamp(date: startOfMonth)
    let endTimestamp = Timestamp(date: endOfMonth)

    do {
        let snapshot = try await Firestore.firestore()
            .collection("workout_done")
            .document(uid)
            .collection("workouts_for_id")
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThanOrEqualTo: endTimestamp)
            .getDocuments()
        
        let workouts: [WorkoutDone] = try snapshot.documents.compactMap {
            try $0.data(as: WorkoutDone.self)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let uniqueDates: Set<String> = Set(workouts.map {
            formatter.string(from: $0.timestamp)
        })
        
        let sortedWorkouts = workouts.sorted { $0.timestamp > $1.timestamp }
        let lastTwo = sortedWorkouts.prefix(2).map {
            (title: $0.workout.name, date: formatter.string(from: $0.timestamp))
        }

        if let sharedDefaults = UserDefaults(suiteName: "group.com.widget.gymbro") {
            sharedDefaults.set(Array(uniqueDates), forKey: "workout_dates")
            
            let titles = lastTwo.map { $0.title }
            let dates = lastTwo.map { $0.date }
            sharedDefaults.set(titles, forKey: "last_workout_titles")
            sharedDefaults.set(dates, forKey: "last_workout_dates")
            
            WidgetCenter.shared.reloadAllTimelines()
            print("данные отправлены")
        }

    } catch {
        print("\(error)")
    }
}

func updateStreak() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    let streakRef = Firestore.firestore().collection("streak").document(uid)
    
    streakRef.getDocument { snapshot, error in
        guard let data = snapshot?.data() else {
            print("No streak data found")
            return
        }
        
        let streak = Streak(data: data)
        let currentWeek = getCurrentWeek()
        
        Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").whereField("week", isEqualTo: currentWeek).getDocuments { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch workouts: \(error.localizedDescription)")
                return
            }
            
            var workoutsThisWeek: [WorkoutDone] = []
            documentSnapshot?.documents.forEach { document in
                do {
                    let workoutDone = try document.data(as: WorkoutDone.self)
                    workoutsThisWeek.append(workoutDone)
                } catch {
                    print("Error decoding workout: \(error.localizedDescription)")
                }
            }
            
            let workoutsCompleted = workoutsThisWeek.count
            let targetWorkouts = streak.numberOfWorkoutsAWeek
            let workoutsLeft = max(targetWorkouts - workoutsCompleted, 0)
            
            let calendar = Calendar(identifier: .iso8601)
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            let daysLeft = max(7 - (weekday - 1), 0)

            let sharedDefaults = UserDefaults(suiteName: "group.com.widget.gymbro")
            sharedDefaults?.set(streak.currentStreak, forKey: "streak_value")
            sharedDefaults?.set(daysLeft, forKey: "days_left_in_week")
            sharedDefaults?.set(workoutsLeft, forKey: "workouts_left_to_complete")
            
            sharedDefaults?.synchronize()
            
            WidgetCenter.shared.reloadAllTimelines()
            print("Streak widget updated")
        }
    }
}

