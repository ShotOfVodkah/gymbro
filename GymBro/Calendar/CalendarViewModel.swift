//
//  CalendarViewModel.swift
//  GymBro
//
//  Created by Stepan Polyakov on 13.04.2025.
//

import Foundation
import FirebaseFirestore

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var calendarDates: [CalendarDate] = []
    @Published var selectedDate: [WorkoutDone] = []

    var workoutCache: [String: [WorkoutDone]] = [:]

    func fetchDates(for date: Date, userMap: [String?: String]) async {
        var calendar = Calendar.current
        calendar.firstWeekday = 2

        guard let interval = calendar.dateInterval(of: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else {
            return
        }

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let from = Timestamp(date: firstDay)
        let to = Timestamp(date: interval.end)
        let ids = userMap.keys.compactMap { $0 }

        let allWorkouts: [WorkoutDone] = await withTaskGroup(of: [WorkoutDone].self) { group in
            for id in ids {
                let cacheKey = "\(id)_\(year)_\(month)"
                if let cached = workoutCache[cacheKey] {
                    group.addTask { cached }
                } else {
                    group.addTask {
                        let path = "workout_done/\(id)/workouts_for_id"
                        do {
                            let snapshot = try await Firestore.firestore()
                                .collection(path)
                                .whereField("timestamp", isGreaterThanOrEqualTo: from)
                                .whereField("timestamp", isLessThanOrEqualTo: to)
                                .getDocuments()

                            let workouts = try snapshot.documents.compactMap {
                                try $0.data(as: WorkoutDone.self)
                            }

                            await MainActor.run {
                                self.workoutCache[cacheKey] = workouts
                            }

                            return workouts
                        } catch {
                            print("Error: \(error)")
                            return []
                        }
                    }
                }
            }

            var combined: [WorkoutDone] = []
            for await result in group {
                combined.append(contentsOf: result)
            }
            return combined
        }

        var groupedWorkouts: [String: [WorkoutDone]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for workout in allWorkouts {
            let key = formatter.string(from: workout.timestamp)
            groupedWorkouts[key, default: []].append(workout)
        }

        let daysInMonth = calendar.dateComponents([.day], from: firstDay, to: interval.end).day ?? 0
        var dates: [CalendarDate] = []

        for day in 1...daysInMonth {
            guard let current = calendar.date(byAdding: .day, value: day - 1, to: firstDay) else { continue }
            let key = formatter.string(from: current)
            let workouts = groupedWorkouts[key] ?? []
            dates.append(CalendarDate(day: day, date: current, workouts: workouts))
        }

        if let firstDate = dates.first {
            var offset = calendar.component(.weekday, from: firstDate.date) - calendar.firstWeekday
            if offset < 0 { offset += 7 }
            for _ in 0..<offset {
                dates.insert(CalendarDate(day: -1, date: Date()), at: 0)
            }
        }

        while dates.count < 42 {
            dates.append(CalendarDate(day: -1, date: Date()))
        }

        self.calendarDates = dates
    }
}
