//
//  Statistics.swift
//  GymBro
//
//  Created by Александра Грицаенко on 08/04/2025.
//

import SwiftUI

struct Statistics: View {
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
                        Text("Statistics")
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.trailing, 60)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    ScrollView{
                        CalendarView(userMap: userMap)
                            .padding(.top,10)
                    }
                    .frame(width: 390)
                    .background(Color("TabBar").opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    Statistics(userMap: ["mHrAJHl1jtReIegIyJC8JbIxj7f1":"Alexandra"])
}
