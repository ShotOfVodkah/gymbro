//
//  AddFriends.swift
//  GymBro
//
//  Created by Александра Грицаенко on 15/04/2025.
//

import SwiftUI

struct AddFriends: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewChatViewModel()
    @State private var searchTerm = ""
    @State private var selectedUsers: Set<String> = []
    
    var filteredUsers: [ChatUser] {
        guard !searchTerm.isEmpty else { return vm.users }
        return vm.users.filter { $0.username.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.gray.opacity(0.7))
                    TextField("Choose someone to follow", text: $searchTerm)
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
                
                ForEach(filteredUsers) { user in
                    let isFriend = vm.friends.contains(user.uid)
                    Button {
                        if !isFriend {
                            if selectedUsers.contains(user.uid) {
                                selectedUsers.remove(user.uid)
                            } else {
                                selectedUsers.insert(user.uid)
                            }
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
                                if isFriend {
                                    Text("Already a friend!")
                                        .font(.system(size: 15))
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .disabled(isFriend)
                    Divider()
                        .padding(.vertical, 5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Friends")
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.addFriends(selectedUsers: selectedUsers)
                        dismiss()
                    } label: {
                        Text("Add")
                            .font(.system(size: 20))
                            .foregroundColor(selectedUsers.isEmpty ? .gray : Color("TitleColor"))
                    }
                    .disabled(selectedUsers.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddFriends()
}
