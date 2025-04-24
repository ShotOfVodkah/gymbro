//
//  GroupAchievements.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct GroupAchievements: View {
    @Binding var bar: Bool
    var body: some View {
        Text("Экран 2")
            .font(.system(size: 35))
            .fontWeight(.semibold)
            .foregroundColor(Color("TitleColor"))
    }
}

#Preview {
    GroupAchievements(bar: .constant(true))
}
