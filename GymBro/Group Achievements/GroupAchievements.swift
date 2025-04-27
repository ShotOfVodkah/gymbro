//
//  GroupAchievements.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct GroupAchievements: View {
    @Binding var bar: Bool
    @StateObject var vm = groupAchievementsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Экран 2")
                            .font(.system(size: 35))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 20)
                        Spacer()
                    }
                    newTeamButton
                    teamsView
                }
                .navigationDestination(isPresented: $shouldNavigateToTeamView) {
//                    team screen
                }
            }
        }
    }
    
    @State var shouldShowNewTeamScreen: Bool = false
    
    private var newTeamButton: some View {
        Button {
            shouldShowNewTeamScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ Create New Team")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.top, -10)
            .padding(.horizontal)
        }.sheet(isPresented: $shouldShowNewTeamScreen) {
            CreateNewTeam()
        }
    }
    
    @State var shouldNavigateToTeamView: Bool = false
    
    private var teamsView: some View {
        ScrollView {
            ForEach(vm.usersTeams) { team in
                VStack {
                    Button {
                        shouldNavigateToTeamView = true
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "figure.socialdance.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(.label))
                            VStack(alignment: .leading) {
                                Text("Team name: \(team.team_name)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text("Owner: \(vm.usernames[team.owner] ?? "")")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.systemGray))
                                Text("Members: \(team.members.compactMap { vm.usernames[$0] }.joined(separator: ", "))")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.systemGray))
                                    .multilineTextAlignment(.leading)
                                Text("Team created: \(team.created_at.formatted(.dateTime.year().month().day()))")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.systemGray))
                            }
                            Spacer()
                            Text(team.created_at.timeAgoDisplay())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                    Divider()
                        .padding(.vertical, 5)
                }
                .padding(.horizontal)
            }
            Spacer().frame(height: 90)
        }
    }
}

#Preview {
    GroupAchievements(bar: .constant(true))
}
