//
//  achievemntsView.swift
//  GymBro
//
//  Created by Александра Грицаенко on 24/04/2025.
//

import SwiftUI

struct AchievementCard: View {
    var achievementName: String
    var iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text(achievementName)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding([.top, .horizontal], 4)
                .lineLimit(2)
        }
        .frame(width: 110, height: 110)
        .background(achievementCompleted(achievementName) ? Color.green : Color.gray)
        .cornerRadius(12)
    }

    private func achievementCompleted(_ achievement: String) -> Bool {
        switch achievement {
        case "Iron Beginner":
            return true
        case "First 100 kg":
            return false
        case "Bench Press Master":
            return true
        case "Never Missed a Day":
            return false
        case "Record Holder":
            return true
        default:
            return false
        }
    }
}
