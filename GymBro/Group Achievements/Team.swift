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
                VStack {
                    currentTeamChallenges
                    Spacer().frame(height: 50)
                }
            }
            .background(Color("Chat"))
            .padding(.bottom, -35)
            .shadow(radius: 10)
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
        ForEach(vm.currentTeamChallengesProgress.sorted(by: { $0.status < $1.status })) { challenge in
            HStack() {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(vm.challengesView[challenge.challenge_id]?.challenge_name ?? "")")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Image("\(vm.challengesView[challenge.challenge_id]?.muscle_group ?? "GymBroBW")")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .padding(.top, 5)
                    let goal_type = vm.challengesView[challenge.challenge_id]?.goal_type ?? ""
                    let goal_amount = vm.challengesView[challenge.challenge_id]?.goal_amount ?? 10000
                    Text("Target: \(goal_type) for \(goal_amount) reps")
                    
                    if challenge.status == 1 {
                        let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: challenge.end_date).day ?? 0
                        Text("Left: \(remainingDays) days")
                    } else {
                        Text("Duration: \(challenge.start_date.formatted(.dateTime.year().month().day())) - \(challenge.end_date.formatted(.dateTime.year().month().day()))")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Total Progress: \(challenge.total_progress)")
                            .font(.headline)
                        ProgressView(value: Double(challenge.total_progress), total: Double(goal_amount))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .frame(height: 6)
                            .clipShape(Capsule())
                            .padding(.trailing, 15)

                        Text("Progress per Member:")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        ForEach(challenge.progress_per_member.sorted(by: { $0.key < $1.key }), id: \.key) { userID, progress in
                            VStack(alignment: .leading) {
                                Text("\(vm.teamUsernames[userID] ?? ""): \(progress)")

                                ProgressView(value: Double(progress), total: Double(challenge.total_progress))
                                    .accentColor(.white)
                                    .frame(height: 6)
                                    .clipShape(Capsule())
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
                .padding(.leading)
                .foregroundColor(.white)
                .frame(width: 380, height: 370)
                .background(.linearGradient(colors: getGradientForStatus(status: challenge.status), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal)
                .padding(.top, 10)
                
                .overlay(Text(getStatusText(status: challenge.status))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding([.bottom], 8)
                    .padding([.trailing], 23),
                         alignment: .bottomTrailing)
                Spacer()
            }
        }
    }
}

func getStatusText(status: Int) -> String {
    switch status {
    case 0: return "Not Started"
    case 1: return "In Progress"
    case 2: return "Successfully finished"
    case 3: return "Failed"
    default: return "Unknown"
    }
}

func getGradientForStatus(status: Int) -> [Color] {
    switch status {
    case 0: return [.black.opacity(0.8), .gray.opacity(0.8)] // haven't started
    case 1: return [Color("PurpleColor").opacity(0.8), .purple.opacity(0.8)] // in progress
    case 2: return [.green.opacity(0.8), .cyan.opacity(0.8)] // finished success
    case 3: return [.red.opacity(0.8), .orange.opacity(0.8)] // finished fail
    default: return [.black.opacity(0.8), .gray.opacity(0.8)]
    }
}

#Preview {
    let data = ["id": "ucAgzXkZgNXbCO7iVedD",
                "team_name": "тюбик",
                "owner": "g9wEOL71fNeTFlLcEhhzWHua1wK2",
                "members": ["v2vtxsjwRHNvazfmMHN2EUZz4U83", "H7BSrUZffMgXJVOdgy3mITSuU7p1", "g9wEOL71fNeTFlLcEhhzWHua1wK2"],
                "created_at": Date()]
    Team(team: Teams(data: data))
}
