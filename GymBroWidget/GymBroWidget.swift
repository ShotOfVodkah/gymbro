//
//  GymBroWidget.swift
//  GymBroWidget
//
//  Created by Stepan Polyakov on 17.04.2025.
//
import WidgetKit
import SwiftUI


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), workoutDates: [], lastWorkouts: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), workoutDates: [], lastWorkouts: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let sharedDefaults = UserDefaults(suiteName: "group.com.widget.gymbro")
        
        let workoutDates = sharedDefaults?.array(forKey: "workout_dates") as? [String] ?? []
        let titles = sharedDefaults?.array(forKey: "last_workout_titles") as? [String] ?? []
        let dates = sharedDefaults?.array(forKey: "last_workout_dates") as? [String] ?? []
        let lastWorkouts = Array(zip(titles, dates))
        
        let currentDate = Date()
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, workoutDates: workoutDates, lastWorkouts: lastWorkouts)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let workoutDates: [String]
    let lastWorkouts: [(title: String, date: String)]
}

struct Workout {
    let title: String
    let date: String
    var id: String {
        return "\(title)-\(date)"
    }
}

struct GymBroWidgetEntryView: View {
    var entry: Provider.Entry

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Last workouts:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("TitleColor"))
                
                let workouts = entry.lastWorkouts.map { workout in
                    Workout(title: workout.title, date: workout.date)
                }
                
                ForEach(workouts, id: \.id) { workout in
                    VStack(spacing: 1){
                        Text("\(workout.date)")
                            .font(.system(size: 10))
                            .foregroundColor(Color("TitleColor"))
                            .opacity(0.7)
                            .frame(maxWidth: 110, alignment: .leading)
                        Text("\(workout.title)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 40)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 10)))
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            .frame(width: 120)
            
            VStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                    let calendar = Calendar.current
                    let monthStartDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: entry.date))!
                    let daysInMonth = calendar.range(of: .day, in: .month, for: monthStartDate)!.count
                    
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .frame(width: 40)
                            .foregroundColor(Color("TitleColor"))
                    }
                    
                    ForEach(1...daysInMonth, id: \.self) { day in
                        let dayString = String(format: "%02d", day)
                        let currentDateString = "\(Calendar.current.component(.year, from: entry.date))-\(String(format: "%02d", Calendar.current.component(.month, from: entry.date)))-\(dayString)"
                        let isWorkoutDay = entry.workoutDates.contains(currentDateString)
                        
                        ZStack {
                            if isWorkoutDay {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color("PurpleColor"), Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 20, height: 20)
                                Text("\(day)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(Color("TitleColor").opacity(0.3))
                                    .frame(width: 20, height: 20)
                                Text("\(day)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("TitleColor"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 200)
            }
            .containerBackground(for: .widget) {
                Color("TabBar")
            }
        }
    }

}

struct GymBroWidget: Widget {
    let kind: String = "GymBroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GymBroWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Сalendar widget")
        .description("Displays your gym activity over the current month")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    GymBroWidget()
} timeline: {
    SimpleEntry(date: .now, workoutDates: ["2025-04-01", "2025-04-05", "2025-04-10"], lastWorkouts: [(title: "Chest", date: "2025-04-15"),(title: "Leg Day", date: "2025-04-13")])
}
