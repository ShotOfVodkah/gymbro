//
//  Account.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct Account: View {
    @Binding var bar: Bool
    @State var shouldShowLogOutOptions: Bool = false
    @StateObject var vm = AccountModel()
    @State private var showMainView = false
    
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
                    settingsButtonView(image: "checkmark.circle.fill", name: Text("Statistics"))
                    settingsButtonView(image: "figure.dance.circle.fill", name: Text("Workout History"))
                    settingsButtonView(image: "person.crop.circle.fill.badge.plus", name: Text("Friends"))
                    settingsButtonView(image: "gear.circle.fill", name: Text("Settings"))
                }
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    Image(systemName: "gear.circle.fill")
                        .font(.system(size: 35))
                        .foregroundColor(Color("TitleColor"))
                }
                Spacer()
            }
            .alert(isPresented: $shouldShowLogOutOptions) {
                Alert(
                    title: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log out"), action: {
                        print("handle log out")
                        vm.handleSignOut()
                    }),
                    secondaryButton: .cancel()
                )
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
                LoginView(didCompleteLogin: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.showMainView = true
                })
            }
            .navigationDestination(isPresented: $showMainView) {
                MainView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
        }
    }
    
    private var customCountBar: some View {
        HStack {
            Button {
                
            } label: {
                VStack {
                    VStack {
                        Text("44")
                            .foregroundColor(Color(.label))
                        Text("Workouts")
                            .foregroundColor(Color(.systemGray))
                    }
                    .padding(.horizontal, 6)
                }
            }
            Divider()
                    .frame(width: 2, height: 30)
                    .background(Color.gray)
            Button {
                
            } label: {
                VStack {
                    Text("0")
                        .foregroundColor(Color(.label))
                    Text("Friends")
                        .foregroundColor(Color(.systemGray))
                }
                .foregroundColor(Color(.label))
                .padding(.horizontal, 6)
            }
            Divider()
                    .frame(width: 2, height: 30)
                    .background(Color.gray)
            Button {
                
            } label: {
                VStack {
                    Text("0 days")
                        .foregroundColor(Color(.label))
                    Text("Streak")
                        .foregroundColor(Color(.systemGray))
                }
                .foregroundColor(Color(.label))
                .padding(.horizontal, 16)
            }
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
            EditProfile()
        }
    }
}

#Preview {
    Account(bar: .constant(true))
}
