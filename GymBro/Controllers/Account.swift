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
    @StateObject var vm = FeedListModel()
    @State private var showMainView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                let username = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "UserName"
                Text("\(username)")
                    .font(.system(size: 35))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TitleColor"))
                    .padding(.vertical, 20)
                customCountBar
                    .padding(.bottom, 20)
                buttonEditProfile
                    .padding(.bottom, 20)
                VStack(spacing: 5) {
                    buttonView(image: "checkmark.circle.fill", name: "Statistics")
                    buttonView(image: "figure.dance.circle.fill", name: "Workout History")
                    buttonView(image: "person.crop.circle.fill.badge.plus", name: "Friends")
                    buttonView(image: "gear.circle.fill", name: "Settings")
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
                    self.vm.fetchExistingChats()
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
    
    private var buttonEditProfile: some View {
        Button {
            
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
    }
}

#Preview {
    Account(bar: .constant(true))
}
