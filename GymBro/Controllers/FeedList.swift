//
//  FeedList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class FeedListModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchExistingChats()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        Firestore.firestore().collection("usersusers").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                print("Faild to fetch user: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No user data"
                return
            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var existingChats = [ExistingChats]()
    private var firestoreListener: ListenerRegistration?
    
    func fetchExistingChats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        firestoreListener?.remove()
        self.existingChats.removeAll()
        firestoreListener = Firestore.firestore().collection("existing_chats").document(uid).collection("messages").order(by: "timestamp").addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to listen for existing messages: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            querySnapshot?.documentChanges.forEach { change in
                if let index = self.existingChats.firstIndex(where: { rm in
                    return rm.documentID == change.document.documentID
                }) {
                    self.existingChats.remove(at: index)
                }
                self.existingChats.insert(.init(documentId: change.document.documentID, data: change.document.data()), at: 0)
            }
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}


struct FeedList: View {
    @Binding var bar: Bool
    @StateObject var vm = FeedListModel()
    @State var shouldNavigateToChatLogView: Bool = false
//    @State private var selectedChatUser: ChatUser?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    customNavigationBar
                    messagesView
                }
                .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                .overlay(newChatButton)
            }
        }
    }
    
    private var customNavigationBar: some View {
        HStack(spacing: 20) {
//                    Image(systemName: "person.circle.fill")
//                        .font(.system(size: 45))
            VStack (alignment: .leading, spacing: 5) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text("\(email)")
                    .font(.system(size: 35))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TitleColor"))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 15, height: 15)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 30))
        }
        .padding()
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.existingChats) { existingChat in
                VStack {
                    Button {
                        let user = ChatUser(data: [
                            "uid": existingChat.fromId == Auth.auth().currentUser?.uid ?? "" ? existingChat.toId : existingChat.fromId,
                            "email": existingChat.email
                        ])
                        print(user.email)
                        print(user.uid)
                        self.chatUser = user
                        shouldNavigateToChatLogView = true
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .padding(5)
                                .overlay(RoundedRectangle(cornerRadius: 40)
                                    .stroke(lineWidth: 1))
                                .foregroundColor(Color(.label))
                            VStack(alignment: .leading) {
                                Text(existingChat.email)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(existingChat.text)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.darkGray))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text(existingChat.timestamp.timeAgoDisplay())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(.label))
                        }
                    }
                    Divider()
                        .padding(.vertical, 5)
                }.padding(.horizontal)
            }.padding(.bottom, 140)
        }
    }
    
    @State var shouldShowNewChatScreen: Bool = false
    @State var chatUser: ChatUser?
    
    private var newChatButton: some View {
        Button {
            shouldShowNewChatScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Chat")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color("PurpleColor"))
            .cornerRadius(50)
            .shadow(radius: 10)
            .padding(.horizontal)
            
        }.offset(y: 270)
            .sheet(isPresented: $shouldShowNewChatScreen) {
                CreateNewChat(didSelectNewUser: { user in
                    print(user.email)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                })
            }
    }
}

#Preview {
    FeedList(bar: .constant(true))
}
