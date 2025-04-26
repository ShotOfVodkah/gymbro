//
//  GymBroStreakWidget.swift
//  GymBroWidget
//
//  Created by Stepan Polyakov on 26.04.2025.
//

import WidgetKit
import SwiftUI

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 0, daysLeft: 0, workoutsLeft: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let entry = StreakEntry(date: Date(), streak: 0, daysLeft: 0, workoutsLeft: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.widget.gymbro")
        let streak = sharedDefaults?.integer(forKey: "streak_value") ?? 0
        let daysLeft = sharedDefaults?.integer(forKey: "days_left_in_week") ?? 0
        let workoutsLeft = sharedDefaults?.integer(forKey: "workouts_left_to_complete") ?? 0
        
        let currentDate = Date()
        let nextMidnight = Calendar.current.nextDate(after: currentDate, matching: DateComponents(hour: 0), matchingPolicy: .nextTime)!

        let entry = StreakEntry(date: currentDate, streak: streak, daysLeft: daysLeft, workoutsLeft: workoutsLeft)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}


struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let daysLeft: Int
    let workoutsLeft: Int
}

struct GymBroStreakWidgetEntryView: View {
    var entry: StreakProvider.Entry

    var body: some View {
        VStack {
            Text("Your streak")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .offset(y: 3)
            ZStack{
                Image(entry.daysLeft < 3 && entry.workoutsLeft != 0 ? "RedFire" : "PurpleFire")
                    .frame(width: 80, height: 80)
                    .scaleEffect(0.30)
                Text("\(entry.streak)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 3, y: 10)
            }
            .offset(y: -5)
            Spacer()
            
            Text("\(entry.workoutsLeft) workouts left")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(entry.daysLeft < 3 && entry.workoutsLeft != 0 ? .red : .purple)
                .padding(5)
                .background(.white)
                .cornerRadius(15)
                .offset(y: -5)
        }
        .containerBackground(for: .widget) {
            if entry.daysLeft < 3 && entry.workoutsLeft != 0 {
                LinearGradient(gradient: Gradient(colors: [Color.red, Color("DarkRed")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
}

struct GymBroStreakWidget: Widget {
    let kind: String = "GymBroStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            GymBroStreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak reminder")
        .description("Shows your current streak and amount of days left")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    GymBroStreakWidget()
} timeline: {
    StreakEntry(date: .now, streak: 10, daysLeft: 2, workoutsLeft: 1)
}
