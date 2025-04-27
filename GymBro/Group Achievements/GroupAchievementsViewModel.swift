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
    @Published var usernames: [String: String] = [:]
    
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
                let team = Teams(data: change.document.data())
                self.usersTeams.insert(team, at: 0)
                for memberUid in team.members {
                    if self.usernames[memberUid] == nil {
                        self.fetchUsernameIfNeeded(uid: memberUid)
                    }
                }
            }
        }
    }
    
    private func fetchUsernameIfNeeded(uid: String) {
        Firestore.firestore().collection("usersusers").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch username for \(uid): \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(), let username = data["username"] as? String {
                DispatchQueue.main.async {
                    self.usernames[uid] = username
                }
            }
        }
    }
}
