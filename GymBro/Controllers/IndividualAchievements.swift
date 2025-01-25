//
//  IndividualAchievements.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct IndividualAchievements: View {
    @Binding var bar: Bool
    var body: some View {
        Text("Экран 4")
            .font(.system(size: 35))
            .fontWeight(.semibold)
            .foregroundColor(Color("TitleColor"))
    }
}

#Preview {
    IndividualAchievements(bar: .constant(true))
}
