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
    
    func fetchChallengesProgress() {
        Firestore.firestore().collection("team_challenge_progress").document(team.id).collection("team_challenges").getDocuments { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch team challenges progress: \(error.localizedDescription)")
                return
            }
            documentSnapshot?.documents.forEach { document in
                var tmp = ProgressChallenges(data: document.data())
                Firestore.firestore().collection("challenges").document(tmp.challenge_id).getDocument() { documentSnapshot, error in
                    if let error = error {
                        print("Failed to fetch challenge: \(error.localizedDescription)")
                        return
                    }
                    self.challengesView[tmp.challenge_id] = Challenge(data: documentSnapshot?.data() ?? [:])
                    let now = Date()
                    if tmp.start_date <= now && now <= tmp.end_date && tmp.status == 0 {
                        self.updateStatus(challenge: tmp, status: 1)
                        tmp.status = 1
                    } else if tmp.end_date < now && tmp.status == 1 {
                        if tmp.total_progress >= self.challengesView[tmp.challenge_id]?.goal_amount ?? 0 {
                            self.updateStatus(challenge: tmp, status: 2)
                            tmp.status = 2
                        } else {
                            self.updateStatus(challenge: tmp, status: 3)
                            tmp.status = 3
                        }
                    }
                    self.currentTeamChallengesProgress.append(tmp)
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
    
    func updateStatus(challenge: ProgressChallenges, status: Int) {
        Firestore.firestore().collection("team_challenge_progress").document(team.id).collection("team_challenges").document(challenge.id).updateData(["status": status]) { error in
            if let error = error {
                print("Failed to update status: \(error.localizedDescription)")
                return
            } else {
                print("Status updated!")
            }
        }
    }
}
