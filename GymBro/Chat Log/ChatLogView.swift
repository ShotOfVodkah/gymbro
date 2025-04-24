//
//  ChatLogView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack() {
                    HStack {
                        dismissButton
                        TitleRow(chatUser: self.chatUser)
                    }
                    .padding(.bottom, 10)
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack{
                                ForEach(Array(vm.messages.enumerated()), id: \.element.id) { index, _ in
                                    MessageBubble(message: $vm.messages[index])
                                }
                                HStack { Spacer() }
                                    .id("empty")
                            }
                            .onReceive(vm.$count) { _ in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo("empty", anchor: .bottom)
                                }
                            }
                            .onAppear {
                                DispatchQueue.main.async {
                                    proxy.scrollTo("empty", anchor: .bottom)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .background(Color("Chat"))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                }
                .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
                .navigationBarHidden(true)
                .padding(.bottom, -8)
                chatBottomBar
                    .background(Color("Chat"))
            }
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
                    guard let uid = self.chatUser?.uid else { return }
                    CreateNewChatViewModel().addFriends(selectedUsers: [uid])
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
    
    private var dismissButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .padding(20)
        }
    }
}


#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: [
            "uid": "1234",
            "email": "name@gmail.com",
            "username": "girl"
        ]))
    }
}
