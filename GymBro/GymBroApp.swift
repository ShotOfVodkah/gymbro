//
//  GymBroApp.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import FirebaseCore
import SwiftUI
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // каким-то макаром перенаправляет в нужное место, но это не точно
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .badge, .banner, .list]
    }
}

@main
struct GymBroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = AccountModel()
    @StateObject var themeManager = AppThemeManager()
    @State private var showLoad = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLoad {
                    LoadingView()
                        .transition(.opacity)
                } else if self.vm.isUserCurrentlyLoggedOut == true {
                    LoginView(didCompleteLogin: {
                        self.vm.isUserCurrentlyLoggedOut = false
                    }) // привет. АГрицаенко
                } else {
                    MainView()
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.selectedTheme)
                        .environmentObject(LanguageManager())
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showLoad = false
                    }
                }
            }
        }
    }
}
