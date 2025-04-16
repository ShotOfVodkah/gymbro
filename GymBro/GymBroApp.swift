//
//  GymBroApp.swift
//  GymBro
//
//  Created by Stepan Polyakov on 18.11.2024.
//

import FirebaseCore
import SwiftUI


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GymBroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = AccountModel()
    @StateObject var themeManager = AppThemeManager()
    
    var body: some Scene {
        WindowGroup {
            if self.vm.isUserCurrentlyLoggedOut == true {
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
    }
}
