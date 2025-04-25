//
//  achievemntsView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import SwiftUI

struct AchievementCard: View {
    
    let achievement: Achievement
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: achievement.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                Text(achievement.achievementName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding([.top, .horizontal], 4)
                    .lineLimit(2)
            }
            .frame(width: 110, height: 110)
            .background {
                if achievement.achievementCompleted {
                    LinearGradient(
                        colors: [Color(.sRGB, red: 0.0, green: 0.5, blue: 0.0), Color(.sRGB, red: 0.3, green: 0.8, blue: 0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.gray
                }
            }
            .cornerRadius(12)
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 0.0 : 1.0)

            VStack {
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(4)
            }
            .frame(width: 110, height: 110)
            .background(.linearGradient(colors: [Color("PurpleColor"), .purple], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(12)
            .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1.0 : 0.0)
        }
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}
