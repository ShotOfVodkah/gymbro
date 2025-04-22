//
//  Account.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct Account: View {
    @Binding var bar: Bool
    @StateObject var vm = AccountModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color("PurpleColor"))
                let username = vm.chatUser?.username ?? ""
                Text("\(username)")
                    .font(.system(size: 35))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TitleColor"))
                    .padding(.bottom, 20)
                customCountBar
                    .padding(.bottom, 20)
                buttonEditProfile
                    .padding(.bottom, 20)
                VStack(spacing: 5) {
                    settingsButtonView(image: "checkmark.circle.fill", name: Text("Statistics"), destination: Statistics(userMap: [vm.chatUser?.uid ?? "" : ""]))
                    settingsButtonView(image: "figure.dance.circle.fill", name: Text("Workout History"), destination: WorkoutHistory())
                    settingsButtonView(image: "person.crop.circle.fill.badge.plus", name: Text("Friends"), destination: Friends())
                    settingsButtonView(image: "gear.circle.fill", name: Text("Settings"), destination: Settings())
                }
                Spacer()
            }
        }
    }
    
    @State private var showWorkoutHistory = false
    @State private var showFriends = false
    @StateObject var wo = WorkoutHistoryModel()
    @StateObject var fr = CreateNewChatViewModel()
    
    private var customCountBar: some View {
        HStack {
            Button {
                showWorkoutHistory = true
            } label: {
                VStack {
                    VStack {
                        Text("\(wo.doneWorkouts.count)")
                            .foregroundColor(Color(.label))
                        Text("Workouts")
                            .foregroundColor(Color(.systemGray))
                    }
                    .padding(.horizontal, 6)
                }
            }
            .sheet(isPresented: $showWorkoutHistory) { WorkoutHistory() }
            Divider()
                .frame(width: 2, height: 30)
                .background(Color.gray)
            Button {
                showFriends = true
            } label: {
                VStack {
                    Text("\(fr.friends.count)")
                        .foregroundColor(Color(.label))
                    Text("Friends")
                        .foregroundColor(Color(.systemGray))
                }
                .foregroundColor(Color(.label))
                .padding(.horizontal, 6)
            }
            .sheet(isPresented: $showFriends) { Friends() }
            Divider()
                .frame(width: 2, height: 30)
                .background(Color.gray)
            VStack {
                HStack {
                    Image("PurpleFire")
                        .resizable()
                        .frame(width: 30, height: 30)
                    let streak = vm.streak?.currentStreak ?? 0
                    Text("\(streak)")
                        .foregroundColor(Color(.label))
                }
                .padding(.bottom, -10)
                Text("Streak")
                    .foregroundColor(Color(.systemGray))
            }
            .foregroundColor(Color(.label))
            .padding(.horizontal, 16)
            
        }
    }
    
    @State var shouldShowEditProfileScreen: Bool = false
    private var buttonEditProfile: some View {
        Button {
            shouldShowEditProfileScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("Edit Profile")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(50)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
        .sheet(isPresented: $shouldShowEditProfileScreen) {
            EditProfile(vm: vm)
        }
    }
}

#Preview {
    Account(bar: .constant(true))
}
