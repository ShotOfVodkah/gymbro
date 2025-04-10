//
//  MessageBubble.swift
//  GymBro
//
//  Created by Александра Грицаенко on 02/04/2025.
//

import SwiftUI
import FirebaseFirestore

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    @State var errorMessage = ""
    @State var currentWorkout: WorkoutDone?
    @State var username = ""
    
    var body: some View {
        if message.isWorkout {
            Button {
               // go to workout info
            } label: {
                VStack {
                    Text("\(username) just finished working out!")
                        .font(.system(size: 20))
                        .foregroundColor(Color("PurpleColor"))
                    HStack(spacing: 15) {
                        Image(systemName: currentWorkout?.workout.icon ?? "")
                            .font(.system(size: 40))
                            .padding(5)
                            .foregroundColor(.white)
                        VStack(alignment: .leading) {
                            Text(currentWorkout?.workout.name ?? "")
                                .font(.system(size: 23, weight: .bold))
                                .foregroundColor(.white)
                            Text((currentWorkout?.comment).flatMap { $0.isEmpty ? "No comment" : $0 } ?? "")
                                .font(.system(size: 17))
                                .multilineTextAlignment(.leading)
                            Text("")
                            Text(currentWorkout?.timestamp.formatted(.dateTime) ?? "")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: 300, alignment: .leading)
                    .padding()
                    .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(30)
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .padding(.horizontal, 10)
            }
            .onAppear { getWorkoutforChat(); getUsername() }
        } else {
            VStack(alignment: message.received ? .leading : .trailing) {
                HStack {
                    Text(message.text)
                        .padding()
                        .background(message.received ? Color.gray : Color("PurpleColor"))
                        .cornerRadius(30)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: 300, alignment: message.received ? .leading: .trailing)
                .onTapGesture {showTime.toggle()}
                if showTime {
                    Text("\(message.timestamp.formatted(.dateTime))")
                        .foregroundColor(Color.gray)
                        .font(.caption)
                        .padding(message.received ? .leading: .trailing, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: message.received ? .leading: .trailing)
            .padding(message.received ? .leading: .trailing)
            .padding(.horizontal, 10)
        }
    }
    
    private func getUsername() {
        Firestore.firestore().collection("usersusers").document(message.fromId).getDocument { documentSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch user: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                self.errorMessage = "User document does not exist"
                print(self.errorMessage)
                return
            }
            let user = ChatUser(data: data)
            self.username = user.username
        }
    }
    
    private func getWorkoutforChat() {
        Firestore.firestore().collection("workout_done").document(message.fromId).collection("workouts_for_id").document(message.workoutId).getDocument { documentSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch workout: \(error.localizedDescription)"
                print(self.errorMessage)
                return
            }
            guard let document = documentSnapshot, document.exists else {
                self.errorMessage = "Workout document does not exist"
                print(self.errorMessage)
                return
            }
            do {
                self.currentWorkout = try document.data(as: WorkoutDone.self)
            } catch {
                self.errorMessage = "Error decoding workout: \(error.localizedDescription)"
                print(self.errorMessage)
            }
        }
    }
}

#Preview {
    MessageBubble(message: Message(documentId: "1",
                                   fromId: "mHrAJHl1jtReIegIyJC8JbIxj7f1",
                                   toId: "nwsy9PklqCb56PrRMnDWuw0195f1",
                                   text: "Hakuna Matata",
                                   received: false,
                                   timestamp: Date(),
                                   isWorkout: false,
                                   workoutId: "uwk0BPZE3nbLhaoyqzuX"))
}
