//
//  WorkoutInfo.swift
//  GymBro
//
//  Created by Stepan Polyakov on 26.01.2025.
//

import SwiftUI

struct WorkoutInfo: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("TabBar").ignoresSafeArea(edges: .all)
            VStack(){
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 0, y: 300)
                    .frame(width: 600, height: 600)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 190, y: 300)
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: -250, y: 200)
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    .offset(x: 50, y: 200)
                    .frame(width: 200, height: 200)
            }
            .frame(width: UIScreen.main.bounds.width, height: 100)
            Blur().clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 25)
                .padding(.vertical, 120)
                .offset(y: 100)
            
        }
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    WorkoutInfo()
}
