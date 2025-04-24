//
//  NotificationsManager.swift
//  GymBro
//
//  Created by Александра Грицаенко on 20/04/2025.
//

import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

@MainActor
class NotificationsManager: ObservableObject {
    
    @Published private(set) var hasPermission: Bool = false
    
    init () {
        Task {
            await getAuthStatus()
        }
    }
    
    func request() async {
        do {
            self.hasPermission = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized,
             .provisional,
             .ephemeral:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
}


func scheduleDailyWorkoutReminder() {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["dailyWorkoutReminder"])
    
    guard UIApplication.shared.applicationIconBadgeNumber > 0 else { return }

    let content = UNMutableNotificationContent()
    content.title = "One more workout💪"
    content.subtitle = "Don't forget to complete your workout!"
    content.body = "\(UIApplication.shared.applicationIconBadgeNumber) workouts to achieve your weekly goal🔥"
    content.sound = .default
    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber)

    var dateComponents = DateComponents()
    dateComponents.hour = 10
    dateComponents.minute = 00
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(identifier: "dailyWorkoutReminder", content: content, trigger: trigger)

    center.add(request) { error in
        if let error = error {
            print("Failed to add streak notification: \(error)")
        }
        print("Added streak notification")
    }
}
