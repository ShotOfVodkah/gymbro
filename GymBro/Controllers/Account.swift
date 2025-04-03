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
                Text("Экран 5")
                    .font(.system(size: 35))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TitleColor"))
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    Image(systemName: "gear.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color("TitleColor"))
                }
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
}

#Preview {
    Account(bar: .constant(true))
}
