//
//  GroupAchievementsViewModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class groupAchievementsViewModel: ObservableObject {
    
    @Published var usersTeams = [Teams]()
    
    init() {
        fetchExistingTeams()
    }
    
    private var firestoreListener: ListenerRegistration?
    
    func fetchExistingTeams() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        firestoreListener?.remove()
        self.usersTeams.removeAll()
        
        firestoreListener = Firestore.firestore().collection("teams").whereField("members", arrayContains: uid).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Failed to listen for users teams: \(error.localizedDescription)")
                return
            }
            
            querySnapshot?.documentChanges.forEach { change in
                if let index = self.usersTeams.firstIndex(where: { rm in
                    return rm.id == change.document.documentID
                }) {
                    self.usersTeams.remove(at: index)
                }
                self.usersTeams.insert(.init(data: change.document.data()), at: 0)
            }
        }
    }
}
