//
//  ChallengesViewModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class ChallengesViewModel: ObservableObject {
    @Published var availableChallenges = [Challenge]()
    
    init() {
        fetchChallenges()
    }
    
    func fetchChallenges() {
        Firestore.firestore().collection("challenges").whereField("start_date", isGreaterThan: Date()).getDocuments() { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch challenges: \(error.localizedDescription)")
                return
            }
            documentSnapshot?.documents.forEach { document in
                self.availableChallenges.append(Challenge(data: document.data()))
            }
            print("All chalenges fetched")
        }
    }
}
