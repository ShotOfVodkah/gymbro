//
//  FeedList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI
import FirebaseAuth

struct FeedList: View {
    @Binding var bar: Bool
    @StateObject var vm = FeedListModel()
    @State var shouldNavigateToChatLogView: Bool = false
    @State var shouldNavigateToAddFriendsView: Bool = false

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
                let username = vm.chatUser?.username ?? ""
                Text("\(username)")
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
            Button {
                shouldNavigateToAddFriendsView.toggle()
            } label: {
                HStack {
                    Text("Add Friends")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("TitleColor"))
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color("TitleColor"))
                }
            }
            .fullScreenCover(isPresented: $shouldNavigateToAddFriendsView) {
                AddFriends()
            }
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
                            "email": existingChat.email,
                            "username": existingChat.username
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
                                Text(existingChat.username)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text(existingChat.text)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(.systemGray))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text(existingChat.timestamp.timeAgoDisplay())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(.systemGray))
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
            .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(50)
            .shadow(radius: 10)
            .padding(.horizontal)
        }.offset(y: 260)
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
