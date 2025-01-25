//
//  Account.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct Account: View {
    @Binding var bar: Bool
    var body: some View {
        Text("Экран 5")
            .font(.system(size: 35))
            .fontWeight(.semibold)
            .foregroundColor(Color("TitleColor"))
    }
}

#Preview {
    Account(bar: .constant(true))
}
