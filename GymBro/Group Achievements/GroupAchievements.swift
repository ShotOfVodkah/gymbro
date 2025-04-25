//
//  GroupAchievements.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct GroupAchievements: View {
    @Binding var bar: Bool
//    @StateObject var vm = groupAchievementsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Экран 2")
                            .font(.system(size: 35))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 20)
                        Spacer()
                    }
                    ScrollView {
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    GroupAchievements(bar: .constant(true))
}
