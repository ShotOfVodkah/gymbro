//
//  CreateNewTeam.swift
//  GymBro
//
//  Created by Александра Грицаенко on 27/04/2025.
//

import SwiftUI

struct CreateNewTeam: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewChatViewModel()
    @State private var searchTerm = ""
    @State private var selectedUsers: Set<String> = []
    @State var teamName: String = ""
    
    var filteredUsers: [ChatUser] {
        guard !searchTerm.isEmpty else { return vm.users }
        return vm.users.filter { $0.username.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AddBackground").ignoresSafeArea()
                VStack{
                    HStack {
                        Text("Your team name:")
                            .font(.system(size: 23, weight: .semibold))
                            .foregroundColor(Color("TitleColor"))
                        TextField("enter team name", text: $teamName)
                            .foregroundColor(Color(.label))
                            .textFieldStyle(.plain)
                            .autocapitalization(.none)
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, -5)

                    ScrollView {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.gray.opacity(0.7))
                            TextField("Choose members for your team", text: $searchTerm)
                        }
                        .padding(9)
                        .background(Color("TabBar"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color("PurpleColor").opacity(0.8), lineWidth: 2)
                        )
                        .padding(.top, 5)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 15)
                        
                        ForEach(filteredUsers) { user in
                            Button {
                                if selectedUsers.contains(user.uid) {
                                    selectedUsers.remove(user.uid)
                                } else {
                                    selectedUsers.insert(user.uid)
                                }
                            } label: {
                                HStack(spacing: 20) {
                                    Image(systemName: selectedUsers.contains(user.uid) ? "checkmark.circle.fill" : "person.fill")
                                        .font(.system(size: 20))
                                        .padding(5)
                                        .overlay(RoundedRectangle(cornerRadius: 40)
                                            .stroke(lineWidth: 1)
                                        )
                                        .foregroundColor(selectedUsers.contains(user.uid) ? .green : Color("TitleColor"))
                                    VStack (alignment: .leading) {
                                        Text(user.username)
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("TitleColor"))
                                        if vm.friends.contains(user.uid) {
                                            Text("Your friend!")
                                                .font(.system(size: 15))
                                                .foregroundColor(.green)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            Divider()
                                .padding(.vertical, 5)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Create new team")
                                .font(.system(size: 29))
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
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                vm.createNewTeam(teamName: teamName, selectedUsers: selectedUsers)
                                dismiss()
                            } label: {
                                Text("Create")
                                    .font(.system(size: 20))
                                    .foregroundColor((selectedUsers.isEmpty || teamName.isEmpty) ? .gray : Color("TitleColor"))
                            }
                            .disabled(selectedUsers.isEmpty)
                            .disabled(teamName.isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreateNewTeam()
}
