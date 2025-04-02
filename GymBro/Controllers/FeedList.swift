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
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}


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
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .padding(5)
                                .overlay(RoundedRectangle(cornerRadius: 40)
                                    .stroke(lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Message sent to user")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("22d")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 5)
                }.padding(.horizontal)
            }.padding(.bottom, 140)
        }
    }
    
    @State var shouldShowNewChatScreen: Bool = false
    
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
    @State var chatUser: ChatUser?
}

#Preview {
    FeedList(bar: .constant(true))
}
