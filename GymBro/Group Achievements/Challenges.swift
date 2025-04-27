//
//  ChallengesView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import SwiftUI

struct Challenges: View {
    var team_id: String
    @StateObject var vm = ChallengesViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    challengesHeader
                    challengesView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var challengesHeader: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("TitleColor"))
                    .font(.system(size: 30))
                    .padding(.leading)
            }
            Text("Available Challenges")
                .font(.system(size: 35))
                .fontWeight(.semibold)
                .foregroundColor(Color("TitleColor"))
                .padding(.leading, 5)
            Spacer()
        }
    }
    
    private var challengesView: some View {
        ScrollView {
            ForEach(vm.availableChallenges) { challenge in
                Button {
                    // add this chall to a team
                } label: {
                    
                }
            }
//            ForEach(vm.usersTeams) { team in
//                VStack {
//                    NavigationLink(destination: TeamView(team: team)) {
//                        HStack(spacing: 15) {
//                            Image(systemName: "figure.socialdance.circle.fill")
//                                .font(.system(size: 40))
//                                .foregroundColor(Color(.label))
//                            VStack(alignment: .leading) {
//                                Text("Team name: \(team.team_name)")
//                                    .font(.system(size: 15, weight: .bold))
//                                    .foregroundColor(Color(.label))
//                                Text("Owner: \(vm.usernames[team.owner] ?? "")")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(Color(.systemGray))
//                                Text("Members: \(team.members.compactMap { vm.usernames[$0] }.joined(separator: ", "))")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(Color(.systemGray))
//                                    .multilineTextAlignment(.leading)
//                                Text("Team created: \(team.created_at.formatted(.dateTime.year().month().day()))")
//                                    .font(.system(size: 15))
//                                    .foregroundColor(Color(.systemGray))
//                            }
//                            Spacer()
//                            Text(team.created_at.timeAgoDisplay())
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundColor(Color(.systemGray))
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
        }
    }
}

#Preview {
    Challenges(team_id: "Sf7roo3RSbDkuaiSqY9d")
}
