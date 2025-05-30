//
//  Friends.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Friends: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = CreateNewChatViewModel()
    @State private var searchTerm = ""
    
    var filteredUsers: [ChatUser] {
        guard !searchTerm.isEmpty else { return vm.users }
        return vm.users.filter { $0.username.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()
                List {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.gray.opacity(0.7))
                        TextField("Search for your friends", text: $searchTerm)
                    }
                    .padding(9)
                    .background(Color("TabBar"))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("PurpleColor").opacity(0.8), lineWidth: 2)
                    )
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    ForEach(filteredUsers) { user in
                        if vm.friends.contains(user.uid) {
                            VStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color("PurpleColor"))
                                        InfoField(title: Text("Username"), isNumber: false, text: .constant(user.username))
                                    }
                                    user.bio.isEmpty ? nil : InfoField(title: Text("Bio"), isNumber: false, text: .constant(user.bio))
                                    HStack {
                                        user.age.isEmpty ? nil : InfoField(title: Text("Age"), isNumber: true, text: .constant(user.age))
                                        user.gender.isEmpty ? nil : GenderPickerField(title: Text("Gender"), selectedGender: .constant(user.gender), shouldShowArrow: false)
                                    }
                                    HStack {
                                        user.weight.isEmpty ? nil : InfoField(title: Text("Weight (kg)"), isNumber: true, text: .constant(user.weight))
                                        user.height.isEmpty ? nil : InfoField(title: Text("Height (cm)"), isNumber: true, text: .constant(user.height))
                                    }
                                    if let streak = vm.friendsStreaks[user.uid] {
                                        HStack {
                                            InfoField(title: Text("Streak"), isNumber: true, text: .constant(String(streak)))
                                            Image("PurpleFire")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }
                                        .padding(.top, (!user.weight.isEmpty || !user.height.isEmpty) ? 0 : 8)
                                    }
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 3)
                                .disabled(true)
                                Divider()
                                    .padding(.horizontal, -17)
                            }
                            .padding(.horizontal)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.removeFriend(uid: user.uid)
                                } label: {
                                    Label("Remove Friend", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Your Friends")
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 20))
                                .foregroundColor(Color("TitleColor"))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Friends()
}
