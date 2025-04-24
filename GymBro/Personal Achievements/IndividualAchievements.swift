//
//  IndividualAchievements.swift
//  GymBro
//
//  Created by Александра Грицаенко on 21.01.25.
//

import SwiftUI

let motivationalQuotes = [
    "🔥 \"Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn’t.\"",
    "💪 \"You haven't failed until you quit trying.\"",
    "⏱ \"Every rep brings you one step closer to your goal.\"",
    "🚀 \"Don’t wait for motivation. Start moving and it will follow.\"",
    "🏋️ \"Results happen over time, not overnight. Keep going.\"",
    "🎯 \"Discipline beats motivation.\"",
    "🧠 \"You’re stronger than you think.\"",
    "⛰️ \"Push yourself, because no one else is going to do it for you.\"",
    "🔥 \"Sweat is just fat crying.\"",
    "🚴 \"Your only limit is you.\""
]

let achievements = [
    "Iron Beginner", "First 100 kg", "Bench Press Master", "Never Missed a Day",
    "Record Holder", "Hard Worker", "Strength Growing", "Night Training",
    "Solo Beast", "Tough Day", "Machine Not a Guy", "Trophy Collection",
    "Fitness Enthusiast", "Consistency King", "Personal Best", "Endurance Pro",
    "Powerhouse", "Late Night Hustle"
]

let achievementIcons: [String: String] = [
    "Iron Beginner": "figure.walk.circle.fill",
    "First 100 kg": "bolt.circle.fill",
    "Bench Press Master": "sportscourt",
    "Never Missed a Day": "calendar.circle.fill",
    "Record Holder": "flame.fill",
    "Hard Worker": "hammer.fill",
    "Strength Growing": "star.circle.fill",
    "Night Training": "moon.stars.fill",
    "Solo Beast": "pawprint.fill",
    "Tough Day": "cloud.sun.rain.fill",
    "Machine Not a Guy": "car.circle.fill",
    "Trophy Collection": "trophy.fill",
    "Fitness Enthusiast": "figure.water.fitness.circle.fill",
    "Consistency King": "crown.fill",
    "Personal Best": "guitars.fill",
    "Endurance Pro": "shield.fill",
    "Powerhouse": "battery.100percent.bolt",
    "Late Night Hustle": "moon.fill"
]

struct IndividualAchievements: View {
    @Binding var bar: Bool
    @StateObject var vm = personalAchievementsModel()
    @State private var currentQuote: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("Экран 4")
                            .font(.system(size: 35))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TitleColor"))
                            .padding(.leading, 20)
                        Spacer()
                    }

                    ScrollView {
                        if !currentQuote.isEmpty {
                            motivationalQuote
                        }
                        streakProgressBar
                        achivementsLayout
                    }
                }
                .onAppear {
                    currentQuote = motivationalQuotes.randomElement() ?? ""
                }
            }
        }
    }
    
    private var motivationalQuote: some View {
        
        HStack {
            Spacer()
            Text(currentQuote)
                .font(.headline)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
        .transition(.opacity)
    }
    
    private var streakProgressBar: some View {
        HStack(spacing: 16) {
            Image("RedFire")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your streak: \(vm.streak?.currentStreak ?? 0) weeks")
                    .font(.headline)
                    .foregroundColor(Color("PurpleColor"))
                
                ProgressView(value: Double((vm.streak?.currentStreak ?? 0) % 52), total: 52)
                    .accentColor(.orange)
                    .frame(height: 6)
                    .clipShape(Capsule())
                
                Text("\(52 - (vm.streak?.currentStreak ?? 0)) more weeks for a full year")
                    .font(.subheadline)
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var achivementsLayout: some View {
        VStack {
            Text("Your achievements")
                .font(.headline)
                .foregroundColor(Color("PurpleColor"))
                .padding(.top, 10)
            TabView {
                ForEach(0..<achievements.count / 6 + (achievements.count % 6 == 0 ? 0 : 1), id: \.self) { tabIndex in
                    VStack {
                        
                        HStack {
                            ForEach(0..<3) { index in
                                let achievementIndex = tabIndex * 6 + index
                                if achievementIndex < achievements.count {
                                    AchievementCard(achievementName: achievements[achievementIndex],
                                                    iconName: achievementIcons[achievements[achievementIndex]] ?? "star.circle.fill"
                                    )
                                }
                            }
                        }

                        HStack {
                            ForEach(3..<6) { index in
                                let achievementIndex = tabIndex * 6 + index
                                if achievementIndex < achievements.count {
                                    AchievementCard(achievementName: achievements[achievementIndex],
                                                    iconName: achievementIcons[achievements[achievementIndex]] ?? "star.circle.fill"
                                    )
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .frame(height: 245)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
        .transition(.opacity)
    }
}

#Preview {
    IndividualAchievements(bar: .constant(true))
}
