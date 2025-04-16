//
//  Settings.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Settings: View {
    @State var shouldShowLogOutOptions: Bool = false
    @State private var showMainView = false
    @StateObject var vm = AccountModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                BackgroundAnimation()
                VStack {
                    HStack {
                        dismissButton
                        Text("Settings")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 50)
                        Spacer()
                    }
                    // theme
                    // language
                    settingsButtonView(image: "person.text.rectangle.fill", name: Text("Profile"), destination: EditProfile())
                    // wo reminders?
                    // about
                    logoutButton
                    //delete account
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 30))
                Text("Back")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 20))
            }
            .padding(.leading, 10)
        }
    }
    
    private var logoutButton: some View {
        Button {
            shouldShowLogOutOptions.toggle()
        } label: {
            Image(systemName: "gear.circle.fill")
                .font(.system(size: 35))
                .foregroundColor(Color("TitleColor"))
        }
        .alert(isPresented: $shouldShowLogOutOptions) {
            Alert(
                title: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log out"), action: {
                    print("handle log out")
                    vm.handleSignOut()
                    showMainView = false
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
        .fullScreenCover(isPresented: $showMainView) {
            MainView()
        }
    }
}

#Preview {
    Settings()
}
