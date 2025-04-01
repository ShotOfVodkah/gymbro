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
    @StateObject var vm = FeedListModel()
    
    var body: some Scene {
        WindowGroup {
            if self.vm.isUserCurrentlyLoggedOut == true {
                LoginView(didCompleteLogin: {
                    self.vm.isUserCurrentlyLoggedOut = false
                }) // привет. АГрицаенко
            } else {
                MainView()
            }
        }
    }
}
