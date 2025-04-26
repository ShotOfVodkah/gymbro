//
//  personalAchievementsModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class personalAchievementsModel: ObservableObject {
    
    @Published var currentUserID: String = Auth.auth().currentUser?.uid ?? ""
    
    init() {
        fetchStreakData()
        fetchUsersRanks()
        fetchAchievements()
    }

    @Published var streak: Streak?
    
    func fetchStreakData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("streak").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching streak for a user: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                print("No streak data")
                return
            }
            self.streak = .init(data: data)
        }
    }
    
    @Published var usersRank: [UserRanking] = []
    
    func fetchUsersRanks() {
        
        Firestore.firestore().collection("usersusers").getDocuments { documentsSnapshot, error in
            if let error = error {
                print("Failed to fetch users: \(error.localizedDescription)")
                return
            }
            
            documentsSnapshot?.documents.forEach { snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                
                Firestore.firestore().collection("workout_done").document(user.uid).collection("workouts_for_id").count.getAggregation(source: .server) { snapshot, error in
                    if let error = error {
                        print("Failed to count workouts: \(error.localizedDescription)")
                        return
                    }
                    
                    let count = snapshot?.count ?? 0
                    
                    Firestore.firestore().collection("friends").document(self.currentUserID).collection("friendsList").document(user.uid).getDocument() { friendDoc, error in
                        let isFriend = friendDoc?.exists == true || user.uid == self.currentUserID
                        
                        Firestore.firestore().collection("streak").document(user.uid).getDocument { streakSnapshot, error in
                            if let error = error {
                                print("Error fetching streak for a user: \(error.localizedDescription)")
                                return
                            }
                            let streak = streakSnapshot?.data()?["currentStreak"] as? Int ?? 0
                            
                            let userRank = UserRanking(id: user.uid,
                                                       username: user.username,
                                                       isFriend: isFriend,
                                                       totalWorkouts: Int(truncating: count),
                                                       currentStreak: streak)
                            DispatchQueue.main.async {
                                self.usersRank.append(userRank)
                                print("Appended userRank for \(user.username)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @Published var selectedScope: UserScope = .all
    @Published var selectedFilter: FilterType = .streak
    
    enum UserScope: String, CaseIterable {
        case all = "All"
        case friends = "Friends"
    }

    enum FilterType: String, CaseIterable {
        case streak = "Streak"
        case total = "Workouts"
    }
    
    var sortedUsers: [UserRanking] {
        let filtered: [UserRanking]
        switch selectedScope {
        case .all:
            filtered = usersRank
        case .friends:
            filtered = usersRank.filter { $0.isFriend }
        }
        
        switch selectedFilter {
        case .streak:
            return filtered.sorted { $0.currentStreak > $1.currentStreak }
        case .total:
            return filtered.sorted { $0.totalWorkouts > $1.totalWorkouts }
        }
    }
    
    @Published var achievements: [Achievement] = []

    func fetchAchievements() {
        
        Firestore.firestore().collection("achievements").getDocuments { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch achievements: \(error.localizedDescription)")
                return
            }
            
            documentSnapshot?.documents.forEach { document in
                let data = document.data()
                self.achievements.append(Achievement(achievementName: data["achievementName"] as? String ?? "",
                                                     description: data["description"] as? String ?? "",
                                                     iconName: data["iconName"] as? String ?? "",
                                                     achievementCompleted: (data["usersCompleted"] as? [String])?.contains(self.currentUserID) ?? false))
            }
            print("All achievements fetched")
        }
    }
}

func markAchievementAsCompleted(achievementID: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    
    Firestore.firestore().collection("achievements").document(achievementID).updateData(["usersCompleted": FieldValue.arrayUnion([uid])]) { error in
        if let error = error {
            print("Failed to mark achievement as completed: \(error.localizedDescription)")
        } else {
            print("Achievement marked as completed successfully.")
        }
    }
}
