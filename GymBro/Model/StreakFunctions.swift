//
//  StreakFunctions.swift
//  GymBro
//
//  Created by Александра Грицаенко on 22/04/2025.
//

import Foundation

func getISOWeek(for date: Date) -> String {
    let calendar = Calendar(identifier: .iso8601)
    let year = calendar.component(.yearForWeekOfYear, from: date)
    let week = calendar.component(.weekOfYear, from: date)
    return "\(year)-W\(String(format: "%02d", week))"
}

func getCurrentWeek() -> String {
    return getISOWeek(for: Date())
}
