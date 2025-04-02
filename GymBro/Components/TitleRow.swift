//
//  TitleRow.swift
//  GymBro
//
//  Created by Александра Грицаенко on 01/04/2025.
//

import SwiftUI

struct TitleRow: View {
    let chatUser: ChatUser?
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .padding(5)
                .overlay(RoundedRectangle(cornerRadius: 40)
                    .stroke(lineWidth: 1))
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                let username = chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "Jane Doe"
                Text("\(username)")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
                Text("Online")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 40))
                .padding(10)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    TitleRow(chatUser: nil)
        .background(Color("BackgroundB"))
}
