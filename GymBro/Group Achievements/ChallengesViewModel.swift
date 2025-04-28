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
    
    func addChalengeToTeam(selectedChallenge: Challenge, team: Teams) {
        var progressPerMember: [String: Int] = [:]
        for memberId in team.members { progressPerMember[memberId] = 0 }
        
        let challengeData = ["challenge_id": selectedChallenge.id,
                             "team_id": team.id,
                             "exercise_id": selectedChallenge.exercise_id,
                             "start_date": selectedChallenge.start_date,
                             "end_date": selectedChallenge.end_date,
                             "total_progress": 0,
                             "progress_per_member": progressPerMember,
                             "status": 0] as [String : Any]
        
        Firestore.firestore().collection("team_challenge_progress").document(team.id).collection("team_challenges").document(selectedChallenge.id).setData(challengeData) { error in
            if let error = error {
                print("Failed to add challenge to team: \(error.localizedDescription)")
                return
            }
            print("Successfully added challenge to team")
        }
        
        var teams_participating = selectedChallenge.teams_participating
        teams_participating.append(team.id)
        Firestore.firestore().collection("challenges").document(selectedChallenge.id).updateData(["teams_participating": teams_participating]) { error in
            if let error = error {
                print("Failed to update teams in challenge: \(error.localizedDescription)")
                return
            } else {
                print("Teams in challenge updated!")
            }
        }
    }
}
