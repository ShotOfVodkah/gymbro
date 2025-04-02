//
//  ChatLogView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


class ChatLogViewModel: ObservableObject {
    
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var messages = [Message]()
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        Firestore.firestore()
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
                    print(data["timestamp"] as? Date ?? Date())
                    self.messages.append(message)
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
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        VStack {
            VStack() {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .padding(20)
                    }
                    TitleRow(chatUser: self.chatUser)
                }
                .padding(.bottom, 10)
                ScrollView {
                    ForEach(vm.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding(.top, 20)
                .background(.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
            }
            .background(Color("PurpleColor"))
            .navigationBarHidden(true)
            chatBottomBar
        }
    }
    
    private var chatBottomBar: some View {
        HStack {
            TextField("Enter your message here", text: $vm.message, axis: .vertical)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1...5)
            Button {
                if vm.message.isEmpty {
                    print("empty")
                } else {
                    vm.handleSend()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("PurpleColor"))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.7))
        .cornerRadius(50)
        .padding()
    }
}


#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: [
            "uid": "REwtwTzvUsRk5ub4T2JalrpgAs43",
            "email": "girl@gmail.com"
        ]))
    }
}
