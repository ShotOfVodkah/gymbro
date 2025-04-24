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
    @Published var streak: Streak?
    
    init() {
        fetchStreakData()
    }

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
}
