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
                                Text(existingChat.email.replacingOccurrences(of: "@gmail.com", with: ""))
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
