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


class AccountModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var streak: Streak?
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        fetchCurrentUser()
        updateUserStreak()
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
        
        Firestore.firestore().collection("streak").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Error fetching streak for a user: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No streak data"
                print(self.errorMessage)
                return
            }
            self.streak = .init(data: data)
        }
    }
    
    func updateUserData(username: String, bio: String, gender: String, age: String, weight: String, height: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        let document = Firestore.firestore().collection("usersusers").document(uid)
        let userData = ["uid": uid, "email": email, "username": username, "bio": bio, "gender": gender, "age": age, "weight": weight, "height": height] as [String : Any]
        document.setData(userData) { error in
            if let error = error {
                self.errorMessage = "Faield to update user data: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully updated user data")
            DispatchQueue.main.async {
                self.chatUser = .init(data: userData)
            }
        }
    }
    
    func updateStreakGoal(numberOfWorkoutsAweek: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let streakData = ["currentStreak": streak?.currentStreak ?? 0, "numberOfWorkoutsAWeek": Int(numberOfWorkoutsAweek) ?? 1, "lastCheckData": streak?.lastCheckData ?? Date(), "lastCheckWeek": streak?.lastCheckWeek ?? getCurrentWeek()] as [String : Any]
        Firestore.firestore().collection("streak").document(uid).setData(streakData) { error in
            if let error = error {
                self.errorMessage = "Faield to update streak data: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            print("Successfully updated streak goal data")
        }
    }
    
    func updateUserStreak() {
        var streak: Streak?
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("streak").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                print("No streak data")
                return
            }
            streak = Streak(data: data)
            let currentWeek = getCurrentWeek()
            
            guard streak?.lastCheckWeek != currentWeek else {
                Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").whereField("week", isEqualTo: currentWeek).getDocuments { documentSnapshot, error in
                    if let error = error {
                        print("Failed to fetch done workouts: \(error.localizedDescription)")
                        return
                    }
                    
                    var filteredWorkouts: [WorkoutDone] = []
                    documentSnapshot?.documents.forEach { document in
                        do {
                            let workoutDone = try document.data(as: WorkoutDone.self)
                            filteredWorkouts.append(workoutDone)
                        } catch {
                            print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                        }
                    }
                    let remainingWorkouts = (streak?.numberOfWorkoutsAWeek ?? 1) - filteredWorkouts.count
                    UIApplication.shared.applicationIconBadgeNumber = max(remainingWorkouts, 0)
                    print("Streak badge updated")
                }
                print("Streak already checked this week")
                return
            }
            
            let previousWeek = streak?.lastCheckWeek ?? "No data"
            print(previousWeek)
            
            Firestore.firestore().collection("workout_done").document(uid).collection("workouts_for_id").whereField("week", isEqualTo: previousWeek).getDocuments { documentSnapshot, error in
                if let error = error {
                    print("Failed to fetch done workouts: \(error.localizedDescription)")
                    return
                }
                
                var filteredWorkouts: [WorkoutDone] = []
                documentSnapshot?.documents.forEach { document in
                    do {
                        let workoutDone = try document.data(as: WorkoutDone.self)
                        filteredWorkouts.append(workoutDone)
                    } catch {
                        print("Error decoding document \(document.documentID): \(error.localizedDescription)")
                    }
                }
                
                let didMeetGoal = filteredWorkouts.count >= streak?.numberOfWorkoutsAWeek ?? 1
                let newStreak = didMeetGoal ? (streak?.currentStreak ?? 0) + 1 : 0
                let newStreakData = ["currentStreak": newStreak, "numberOfWorkoutsAWeek": streak?.numberOfWorkoutsAWeek ?? 1, "lastCheckData": Date(), "lastCheckWeek": currentWeek]
                
                Firestore.firestore().collection("streak").document(uid).updateData(newStreakData) { error in
                    if let error = error {
                        print("Failed to update streak: \(error.localizedDescription)")
                    } else {
                        print("Streak updated: \(newStreak)")
                        DispatchQueue.main.async {
                            self.streak = .init(data: newStreakData)
                        }
                    }
                }
            }
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
    
    func handleDeleteAccount() {
        isUserCurrentlyLoggedOut.toggle()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let collections = ["usersusers/", "streak/", "workouts/", "workout_done/", "friends/", "existing_chats/"]
        let subcollections = ["workout_done/\(uid)/workouts_for_id", "workouts/\(uid)/workouts_for_id"]
        
        let dispatchGroup = DispatchGroup()

        for path in subcollections {
            dispatchGroup.enter()
            db.collection(path).getDocuments { snapshot, error in
                guard let docs = snapshot?.documents, error == nil else {
                    dispatchGroup.leave()
                    return
                }
                let innerGroup = DispatchGroup()
                for doc in docs {
                    innerGroup.enter()
                    db.collection(path).document(doc.documentID).delete { error in
                        if let error = error {
                            print("Failed to delete document \(doc.documentID): \(error.localizedDescription)")
                        }
                        innerGroup.leave()
                    }
                }
                innerGroup.notify(queue: .main) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.enter()
        db.collection("existing_chats/\(uid)/messages").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                dispatchGroup.leave()
                return
            }
            
            let innerGroup = DispatchGroup()
            for doc in docs {
                let friendId = doc.documentID
                innerGroup.enter()
                db.collection("existing_chats/\(uid)/messages").document(friendId).delete { error in
                    if let error = error {
                        print("Failed to delete chat document from \(uid): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
                
                innerGroup.enter()
                db.collection("existing_chats/\(friendId)/messages").document(uid).delete { error in
                    if let error = error {
                        print("Failed to delete mirrored chat from \(friendId): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
            }
            
            innerGroup.notify(queue: .main) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        db.collection("friends/\(uid)/friendsList").getDocuments { snapshot, error in
            guard let docs = snapshot?.documents, error == nil else {
                dispatchGroup.leave()
                return
            }
            
            let innerGroup = DispatchGroup()
            for doc in docs {
                let friendId = doc.documentID
                innerGroup.enter()
                db.collection("friends/\(uid)/friendsList").document(friendId).delete { error in
                    if let error = error {
                        print("Failed to delete chat document from \(uid): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
                
                innerGroup.enter()
                db.collection("friends/\(friendId)/friendsList").document(uid).delete { error in
                    if let error = error {
                        print("Failed to delete mirrored chat from \(friendId): \(error.localizedDescription)")
                    }
                    innerGroup.leave()
                }
            }
            
            innerGroup.notify(queue: .main) {
                dispatchGroup.leave()
            }
        }
        
        for path in collections {
            dispatchGroup.enter()
            db.document("\(path)\(uid)").delete { error in
                if let error = error {
                    print("Failed to delete document \(path)\(uid): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error deleting user: \(error.localizedDescription)")
                } else {
                    print("Account successfully deleted.")
                }
            }
        }
    }
}
