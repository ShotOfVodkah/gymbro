//
//  TeamViewModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 28/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class TeamViewModel: ObservableObject {
    @Published var currentTeamChallengesProgress = [ProgressChallenges]()
    @Published var teamUsernames = [String: String]()
    @Published var challengesView = [String: Challenge]()
    
    var team: Teams
    
    init(team: Teams) {
        self.team = team
        fetchChallengesProgress()
    }
    
    // UPDATE STATUS
    
    func fetchChallengesProgress() {
        Firestore.firestore().collection("team_challenge_progress").document(team.id).collection("team_challenges").order(by: "status", descending: false).getDocuments { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch team challenges progress: \(error.localizedDescription)")
                return
            }
            documentSnapshot?.documents.forEach { document in
                let tmp = ProgressChallenges(data: document.data())
                self.currentTeamChallengesProgress.append(tmp)
                Firestore.firestore().collection("challenges").document(tmp.challenge_id).getDocument() { documentSnapshot, error in
                    if let error = error {
                        print("Failed to fetch challenge: \(error.localizedDescription)")
                        return
                    }
                    self.challengesView[tmp.challenge_id] = Challenge(data: documentSnapshot?.data() ?? [:])
                    print("Challenge fetched")
                }
            }
            print("All challenges fetched")
        }
        
        for memberId in team.members {
            Firestore.firestore().collection("usersusers").document(memberId).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch username for \(memberId): \(error.localizedDescription)")
                    return
                }
                if let data = snapshot?.data(), let username = data["username"] as? String {
                    DispatchQueue.main.async {
                        self.teamUsernames[memberId] = username
                    }
                }
            }
        }
    }
}
