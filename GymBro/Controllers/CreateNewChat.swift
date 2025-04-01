//
//  CreateNewChat.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class CreateNewChatViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }

    private func fetchAllUsers() {
        Firestore.firestore().collection("usersusers").getDocuments { documentsSnapshot, error in
            if let error = error {
                print("Failed to fetch users: \(error.localizedDescription)")
                return
            }
            documentsSnapshot?.documents.forEach { snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid != Auth.auth().currentUser?.uid {
                    self.users.append(.init(data: data))
                }
            }
        }
    }
}

struct CreateNewChat: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewChatViewModel()
    @State private var searchTerm = ""
    
    var filteredUsers: [ChatUser] {
        guard !searchTerm.isEmpty else { return vm.users }
        return vm.users.filter { $0.email.localizedCaseInsensitiveContains(searchTerm) }
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
                            Text(user.email)
                                .font(.system(size: 20))
                                .foregroundColor(Color("TitleColor"))
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
