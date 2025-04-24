//
//  ChatLogViewModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import Foundation

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
                                          timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                                          isWorkout: data["isWorkout"] as? Bool ?? false,
                                          workoutId: data["workoutId"] as? String ?? "",
                                          reactions: data["reactions"] as? [String] ?? [""])
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
        let documentId = UUID().uuidString
        let document = Firestore.firestore().collection("messages").document(fromId).collection(toId).document(documentId)
        let messageData = ["fromId": fromId, "toId": toId, "text": self.message, "timestamp": Date(), "received": false,
                           "isWorkout": false, "workoutId": "", "reactions": []] as [String : Any]
        
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
        let recipientDocument = Firestore.firestore().collection("messages").document(toId).collection(fromId).document(documentId)
        let recipientmessageData = ["fromId": fromId, "toId": toId, "text": self.message, "timestamp": Date(), "received": true,
                                    "isWorkout": false, "workoutId": "", "reactions": []] as [String : Any]
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
                    "email": self.chatUser?.email ?? "", "username": self.chatUser?.username ?? "",
                    "isWorkout": false, "workoutId": ""] as [String : Any]
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
                                 "email": email, "username": currentUsername,
                                 "isWorkout": false, "workoutId": ""] as [String : Any]
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
