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
    
    var body: some View {
        NavigationStack {
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
}

#Preview {
    Settings()
}
