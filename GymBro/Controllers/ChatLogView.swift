//
//  ChatLogView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    @Environment(\.dismiss) var dismiss
    var messageArray = ["Hey", "Rise and shine", "Go Kylie go", "You doing amazing sweetie", "Look at her go", "Just an inchident on the race"]
    
    var body: some View {
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
                ForEach (messageArray, id: \.self) { text in
                    MessageBubble(message: Message(id: "12345", text: text, received: false, timestamp: Date()))
                }
            }
            .padding(.top, 20)
            .background(.white)
            .cornerRadius(30, corners: [.topLeft, .topRight])
        }
        .background(Color("PurpleColor"))
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationView {
        ChatLogView(chatUser: .init(data: [
            "uid": "Uiqx9ngra1e5JIXOWN08aEfi2tc2",
            "email": "g1@gmail.com"
        ]))
    }
}
