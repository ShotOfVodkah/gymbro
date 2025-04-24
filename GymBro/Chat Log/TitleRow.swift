//
//  TitleRow.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI
import FirebaseAuth

struct TitleRow: View {
    let chatUser: ChatUser?
    @StateObject var vm = AccountModel()
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: 40)
                    .stroke(lineWidth: 1))
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                let username = chatUser?.username ?? "Jane Doe"
                Text("\(username)")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
                Text("Online")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            NavigationLink {
                ChatCalendar(userMap: [chatUser?.uid ?? "": chatUser?.username ?? "",
                                       vm.chatUser?.uid ?? "" : vm.chatUser?.username ?? ""])
            } label: {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 40))
                    .padding(10)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    TitleRow(chatUser: nil)
        .background(Color("BackgroundB"))
}
