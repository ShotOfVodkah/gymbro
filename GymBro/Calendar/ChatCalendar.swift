//
//  ChatCalendar.swift
//  GymBro
//
//  Created by Stepan Polyakov on 17.04.2025.
//

import SwiftUI

struct ChatCalendar: View {
    
    @Environment(\.dismiss) private var dismiss
    var userMap: [String: String]
    
    var body: some View {
        ZStack {
            BackgroundAnimation().ignoresSafeArea(.all)
            
            NavigationStack {
                VStack{
                    HStack{
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 30))
                                .foregroundColor(Color("TitleColor"))
                            
                        }
                        .padding(.leading, 30)
                        Spacer()
                        Text("Chat activity")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.trailing, 60)
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    CalendarView(userMap: userMap)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ChatCalendar(userMap: ["mHrAJHl1jtReIegIyJC8JbIxj7f1":"Alexandra", "nwsy9PklqCb56PrRMnDWuw0195f1":"Stepan"])
}
