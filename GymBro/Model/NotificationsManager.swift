//
//  NotificationsManager.swift
//  GymBro
//
//  Created by Александра Грицаенко on 20/04/2025.
//

import Foundation
import UserNotifications

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
