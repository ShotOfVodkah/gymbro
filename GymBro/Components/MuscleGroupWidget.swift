//
//  MuscleGroupWidget.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.01.2025.
//

import SwiftUI

struct MuscleGroupWidget: View {
    var info: String
    var body: some View {
        ZStack(){
            BackgroundAnimation().scaleEffect(0.5)
            HStack() {
                Image(systemName: info)
                    .font(.system(size: 80))
                    .foregroundColor(Color("TitleColor"))
                Spacer()
                Text(info)
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color("TitleColor"))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 30))
                    .foregroundColor(Color("TitleColor"))
                    .padding(.trailing, 15)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .frame(width: 340, height: 100)
    }
}

#Preview {
    MuscleGroupWidget(info: "figure.american.football")
}
