//
//  MessageBubble.swift
//  GymBro
//
//  Created by Александра Грицаенко on 02/04/2025.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
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

#Preview {
    MessageBubble(message: Message(documentId: "1",
                                   fromId: "12345",
                                   toId: "34567",
                                   text: "Hakuna Matata",
                                   received: "12345" != "12345",
                                   timestamp: Date()))
    
}
