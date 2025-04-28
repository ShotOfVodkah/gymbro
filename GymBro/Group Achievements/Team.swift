//
//  TeamView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import SwiftUI

struct Team: View {
    var team: Teams
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: TeamViewModel

    init(team: Teams) {
        self.team = team
        _vm = StateObject(wrappedValue: TeamViewModel(team: team))
    }
    
    var body: some View {
        VStack {
            TeamTitleRow
            ScrollView {
                currentTeamChallenges
            }
            .background(Color("Chat"))
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .padding(.bottom, -35)
        }
        .navigationBarHidden(true)
        .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
    }
    
    private var TeamTitleRow: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .padding(.leading)
            }
            Image(systemName: "figure.2.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                Text("\(team.team_name)")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            NavigationLink {
                Challenges(team: team)
            } label: {
                VStack(alignment: .trailing) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("Add challenge")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var currentTeamChallenges: some View {
        ForEach(vm.currentTeamChallengesProgress) { challenge in
            HStack() {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Challenge ID: \(vm.challengesView[challenge.challenge_id]?.challenge_name ?? "")")
                        .font(.headline)
                    Text("Total Progress: \(challenge.total_progress)")
                    Text("Status: \(challenge.status)")
                    
                    VStack(alignment: .leading) {
                        Text("Progress per Member:")
                            .font(.subheadline)
                        ForEach(challenge.progress_per_member.sorted(by: { $0.key < $1.key }), id: \.key) { userID, progress in
                            Text("\(vm.teamUsernames[userID] ?? ""): \(progress)")
                        }
                    }
                }
                .padding()
                .foregroundColor(.black)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

// 0 - haven't started
// 1 - in progress
// 2 - finished success
// 3 - finished fail

#Preview {
    let data = ["id": "ucAgzXkZgNXbCO7iVedD",
                "team_name": "тюбик",
                "owner": "g9wEOL71fNeTFlLcEhhzWHua1wK2",
                "members": ["v2vtxsjwRHNvazfmMHN2EUZz4U83", "H7BSrUZffMgXJVOdgy3mITSuU7p1", "g9wEOL71fNeTFlLcEhhzWHua1wK2"],
                "created_at": Date()]
    Team(team: Teams(data: data))
}
