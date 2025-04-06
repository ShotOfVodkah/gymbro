//
//  FeedFunctions.swift
//  GymBro
//
//  Created by Александра Грицаенко on 03/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class ChatLogViewModel: ObservableObject {
    
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var messages = [Message]()
    @Published var count = 0
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        messages.removeAll()
        firestoreListener = Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch messages cause \(error.localizedDescription)"
                    print(self.errorMessage)
                    return
                }
            querySnapshot?.documentChanges.forEach { change in
                if change.type == .added {
                    let data = change.document.data()
                    let message = Message(documentId: change.document.documentID,
                                          fromId: data["fromId"] as? String ?? "",
                                          toId: data["toId"] as? String ?? "",
                                          text: data["text"] as? String ?? "",
                                          received: data["received"] as? Bool ?? false,
                                          timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date())
                    self.messages.append(message)
                    self.count += 1
                }
            }
        }
        
    }
    
    func handleSend() {
        print(message)
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        let document = Firestore.firestore().collection("messages").document(fromId).collection(toId).document()
        let messageData = ["fromId": fromId, "toId": toId, "text": self.message, "timestamp": Date(), "received": false] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message cause \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully sent message")
            self.persistRecentMessage()
            self.message = ""
        }
        let recipientDocument = Firestore.firestore().collection("messages").document(toId).collection(fromId).document()
        let recipientmessageData = ["fromId": fromId, "toId": toId, "text": self.message, "timestamp": Date(), "received": true] as [String : Any]
        recipientDocument.setData(recipientmessageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message cause \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully received message")
        }
    }
    
    func persistRecentMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        let document = Firestore.firestore().collection("existing_chats").document(uid).collection("messages").document(toId)
        let data = ["timestamp": Date(), "text": self.message, "fromId": uid, "toId": toId,
                    "email": self.chatUser?.email ?? "", "username": self.chatUser?.username ?? ""
        ] as [String : Any]
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save chat document: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully saved chat document")
        }
        let recipientDocument = Firestore.firestore().collection("existing_chats").document(toId).collection("messages").document(uid)
        guard let email = Auth.auth().currentUser?.email else { return }
        let message = self.message
        Firestore.firestore().collection("usersusers").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            let currentUsername: String
            if let username = snapshot?.data()?["username"] as? String {
                currentUsername = username
            } else {
                currentUsername = email
            }
            let recipientData = ["timestamp": Date(), "text": message, "fromId": uid, "toId": toId,
                                 "email": email, "username": currentUsername
            ] as [String : Any]
            recipientDocument.setData(recipientData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save chat document: \(error.localizedDescription)"
                    print(self.errorMessage)
                    return
                }
                print("Successfully saved recipient chat document")
            }
        }
    }
}


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
}
