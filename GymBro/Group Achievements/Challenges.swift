//
//  ChallengesView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import SwiftUI

struct Challenges: View {
    var team: Teams
    @StateObject var vm = ChallengesViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
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
    
    @State private var expandedChallengeId: String? = nil
    
    private var challengesView: some View {
        ScrollView {
            let availableChallenges = vm.availableChallenges.filter { !$0.teams_participating.contains(team.id) }
            
            if availableChallenges.isEmpty {
                Text("No challenges available at the moment(((")
                    .font(.headline)
                    .foregroundColor(Color("TitleColor"))
                    .padding()
            } else {
                ForEach(availableChallenges) { challenge in
                    ZStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image("\(challenge.muscle_group)")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                VStack(alignment: .center) {
                                    Text(challenge.challenge_name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    VStack(alignment: .leading) {
                                        Text("Target: \(challenge.goal_type)")
                                        Text("Aiming for: \(challenge.goal_amount) reps")
                                        Text("Duration: \(challenge.start_date.formatted(.dateTime.year().month().day())) - \(challenge.end_date.formatted(.dateTime.year().month().day()))")
                                        Text("\(challenge.teams_participating.count) teams already joined!")
                                    }
                                }
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(20)
                            .zIndex(1)
                            .onTapGesture {
                                withAnimation {
                                    if expandedChallengeId == challenge.id {
                                        expandedChallengeId = nil
                                    } else {
                                        vm.addChalengeToTeam(selectedChallenge: challenge, team: team)
                                        dismiss()
                                    }
                                }
                            }
                            
                            if expandedChallengeId == challenge.id {
                                ZStack {
                                    Text(challenge.description)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .background(Color("PurpleColor"))
                                        .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))
                                        .padding(.top, -8.5)
                                        .padding(.horizontal, 20)
                                        .animation(.easeInOut(duration: 0.3), value: expandedChallengeId)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .onLongPressGesture {
                            withAnimation {
                                if expandedChallengeId != challenge.id {
                                    expandedChallengeId = challenge.id
                                } else {
                                    expandedChallengeId = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let data = ["id": "Sf7roo3RSbDkuaiSqY9d",
                "team_name": "My first team",
                "owner": "g9wEOL71fNeTFlLcEhhzWHua1wK2",
                "members": ["v2vtxsjwRHNvazfmMHN2EUZz4U83", "Ssw2gP6bBPVOCzMLzrmQkGWMGx42", "H7BSrUZffMgXJVOdgy3mITSuU7p1", "g9wEOL71fNeTFlLcEhhzWHua1wK2"],
                "created_at": Date()]
    Challenges(team: Teams(data: data))
}
