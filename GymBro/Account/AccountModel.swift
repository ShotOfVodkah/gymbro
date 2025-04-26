//
//  FeedFunctions.swift
//  GymBro
//
//  Created by Александра Грицаенко on 03/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class AccountModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var streak: Streak?
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        fetchCurrentUser()
        updateUserStreak()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        Firestore.firestore().collection("usersusers").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                print("Faild to fetch user: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No user data"
                return
            }
            self.chatUser = .init(data: data)
        }
        
        Firestore.firestore().collection("streak").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching streak for a user: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No streak data"
                print(self.errorMessage)
                return
            }
            self.streak = .init(data: data)
        }
    }
    
    func updateUserData(username: String, bio: String, gender: String, age: String, weight: String, height: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        let document = Firestore.firestore().collection("usersusers").document(uid)
        let userData = ["uid": uid, "email": email, "username": username, "bio": bio, "gender": gender, "age": age, "weight": weight, "height": height] as [String : Any]
        document.setData(userData) { error in
            if let error = error {
                self.errorMessage = "Faield to update user data: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully updated user data")
            DispatchQueue.main.async {
                self.chatUser = .init(data: userData)
            }
        }
    }
    
    func updateStreakGoal(numberOfWorkoutsAweek: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let streakData = ["currentStreak": streak?.currentStreak ?? 0, "numberOfWorkoutsAWeek": Int(numberOfWorkoutsAweek) ?? 1, "lastCheckData": streak?.lastCheckData ?? Date(), "lastCheckWeek": streak?.lastCheckWeek ?? getCurrentWeek()] as [String : Any]
        Firestore.firestore().collection("streak").document(uid).setData(streakData) { error in
            if let error = error {
                self.errorMessage = "Faield to update streak data: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully updated streak goal data")
        }
    }
    
    func updateUserStreak() {
        var streak: Streak?
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("streak").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                print("No streak data")
                return
            }
            streak = Streak(data: data)
            let currentWeek = getCurrentWeek()
            
            guard streak?.lastCheckWeek != currentWeek else {
                Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").whereField("week", isEqualTo: currentWeek).getDocuments { documentSnapshot, error in
                    if let error = error {
                        print("Failed to fetch done workouts: \(error.localizedDescription)")
                        return
                    }
                    
                    var filteredWorkouts: [WorkoutDone] = []
                    documentSnapshot?.documents.forEach { document in
                        do {
                            let workoutDone = try document.data(as: WorkoutDone.self)
                            filteredWorkouts.append(workoutDone)
                        } catch {
                            print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                        }
                    }
                    let remainingWorkouts = (streak?.numberOfWorkoutsAWeek ?? 1) - filteredWorkouts.count
                    UIApplication.shared.applicationIconBadgeNumber = max(remainingWorkouts, 0)
                    print("Streak badge updated")
                }
                print("Streak already checked this week")
                return
            }
            
            let previousWeek = streak?.lastCheckWeek ?? "No data"
            print(previousWeek)
            
            Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").whereField("week", isEqualTo: previousWeek).getDocuments { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch done workouts: \(error.localizedDescription)")
                    return
                }
                
                var filteredWorkouts: [WorkoutDone] = []
                documentSnapshot?.documents.forEach { document in
                    do {
                        let workoutDone = try document.data(as: WorkoutDone.self)
                        filteredWorkouts.append(workoutDone)
                    } catch {
                        print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                    }
                }
                
                let didMeetGoal = filteredWorkouts.count >= streak?.numberOfWorkoutsAWeek ?? 1
                let newStreak = didMeetGoal ? (streak?.currentStreak ?? 0) + 1 : 0
                let newStreakData = ["currentStreak": newStreak, "numberOfWorkoutsAWeek": streak?.numberOfWorkoutsAWeek ?? 1, "lastCheckData": Date(), "lastCheckWeek": currentWeek]
                if filteredWorkouts.count == 7 {
                    markAchievementAsCompleted(achievementID: "iFHP9xhgpNNCNFGNG8RL")
                }
                
                Firestore.firestore().collection("streak").document(uid).updateData(newStreakData) { error in
                    if let error = error {
                        print("Failed to update streak: \(error.localizedDescription)")
                    } else {
                        print("Streak updated: \(newStreak)")
                        DispatchQueue.main.async {
                            self.streak = .init(data: newStreakData)
                        }
                    }
                }
            }
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
    
    func handleDeleteAccount() {
        isUserCurrentlyLoggedOut.toggle()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let collections = ["usersusers/", "streak/", "workouts/", "workout_done/", "friends/", "existing_chats/"]
        let subcollections = ["workout_done/\(uid)/workouts_for_id", "workouts/\(uid)/workouts_for_id"]
        
        let dispatchGroup = DispatchGroup()

        for path in subcollections {
            dispatchGroup.enter()
            db.collection(path).getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    dispatchGroup.leave()
                    return
                }
                let innerGroup = DispatchGroup()
                for doc in docs {
                    innerGroup.enter()
                    db.collection(path).document(doc.documentID).delete { error in
                        if let error = error {
                            print("Failed to delete document \(doc.documentID): \(error.localizedDescription)")
                        }
                        innerGroup.leave()
                    }
                }
                innerGroup.notify(queue: .main) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.enter()
        db.collection("existing_chats/\(uid)/messages").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                dispatchGroup.leave()
                return
            }
            
            let innerGroup = DispatchGroup()
            for doc in docs {
                let friendId = doc.documentID
                innerGroup.enter()
                db.collection("existing_chats/\(uid)/messages").document(friendId).delete { error in
                    if let error = error {
                        print("Failed to delete chat document from \(uid): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
                
                innerGroup.enter()
                db.collection("existing_chats/\(friendId)/messages").document(uid).delete { error in
                    if let error = error {
                        print("Failed to delete mirrored chat from \(friendId): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
            }
            
            innerGroup.notify(queue: .main) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        db.collection("friends/\(uid)/friendsList").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                dispatchGroup.leave()
                return
            }
            
            let innerGroup = DispatchGroup()
            for doc in docs {
                let friendId = doc.documentID
                innerGroup.enter()
                db.collection("friends/\(uid)/friendsList").document(friendId).delete { error in
                    if let error = error {
                        print("Failed to delete chat document from \(uid): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
                
                innerGroup.enter()
                db.collection("friends/\(friendId)/friendsList").document(uid).delete { error in
                    if let error = error {
                        print("Failed to delete mirrored chat from \(friendId): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
            }
            
            innerGroup.notify(queue: .main) {
                dispatchGroup.leave()
            }
        }
        
        for path in collections {
            dispatchGroup.enter()
            db.document("\(path)\(uid)").delete { error in
                if let error = error {
                    print("Failed to delete document \(path)\(uid): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                } else {
                    print("Account successfully deleted.")
                }
            }
        }
    }
}
