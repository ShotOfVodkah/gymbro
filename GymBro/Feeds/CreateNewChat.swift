//
//  CreateNewChat.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI


struct CreateNewChat: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewChatViewModel()
    @State private var searchTerm = ""
    
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
                    TextField("Choose users for your chat", text: $searchTerm)
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
                    Button {
                        dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 20) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .padding(5)
                                .overlay(RoundedRectangle(cornerRadius: 40)
                                    .stroke(lineWidth: 1))
                                .foregroundColor(Color("TitleColor"))
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
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Chat")
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

#Preview {
    CreateNewChat(didSelectNewUser: { user in
        print(user.email)
    })
}
