//
//  CreateNewChatViewModel.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


class CreateNewChatViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var friends: Set<String> = []
    @Published var friendsStreaks: [String: Int] = [:]

    init() {
        fetchAllUsers()
    }

    private func fetchAllUsers() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("usersusers").order(by: "username").getDocuments { documentsSnapshot, error in
            if let error = error {
                print("Failed to fetch users: \(error.localizedDescription)")
                return
            }
            documentsSnapshot?.documents.forEach { snapshot in
                let data = snapshot.data()
                let user = ChatUser(data: data)
                if user.uid != currentUser {
                    self.users.append(.init(data: data))
                }
            }
        }
        
        Firestore.firestore().collection("friends").document(currentUser).collection("friendsList").getDocuments { documentsSnapshot, error in
            if let error = error {
                print("Failed to fetch friends: \(error.localizedDescription)")
                return
            }
            documentsSnapshot?.documents.forEach { snapshot in
                if let uid = snapshot.data()["friend_uid"] as? String {
                    self.friends.insert(uid)
                    Firestore.firestore().collection("streak").document(uid).getDocument { streakSnapshot, error in
                        let data = streakSnapshot?.data()
                        self.friendsStreaks[uid] =  data?["currentStreak"] as? Int ?? 0
                    }
                }
            }
        }
    }
    
    func addFriends(selectedUsers: Set<String>) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore().collection("friends").document(currentUser).collection("friendsList")
        
        for user in selectedUsers {
            db.whereField("friend_uid", isEqualTo: user).getDocuments { snapshot, error in
                if let error = error {
                    print("Failed to add a friend: \(error.localizedDescription)")
                    return
                }
                if let documents = snapshot?.documents, documents.isEmpty {
                    db.document(user).setData(["friend_uid": user]) { error in
                        if let error = error {
                            print("Failed to add a friend: \(error.localizedDescription)")
                        } else {
                            print("Friend successfully added: \(user)")
                        }
                    }
                } else {
                    print("Friend already exists: \(user)")
                }
            }
        }
    }
    
    func removeFriend(uid: String) {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore().collection("friends").document(currentUser).collection("friendsList")
        
        db.whereField("friend_uid", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Failed to find friend for deletion: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Failed to delete friend: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.friends.remove(uid)
                        }
                        print("Friend successfully deleted: \(uid)")
                    }
                }
            }
        }
    }
}
