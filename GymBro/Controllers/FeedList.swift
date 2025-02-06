//
//  FeedList.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

struct FeedList: View {
    @Binding var bar: Bool
    var body: some View {
        Text("Экран 1")
            .font(.system(size: 35))
            .fontWeight(.semibold)
            .foregroundColor(Color("TitleColor"))
        
    }
}

#Preview {
    FeedList(bar: .constant(true))
}
