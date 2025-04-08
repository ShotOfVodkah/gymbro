//
//  WatchDataManager.swift
//  GymBro Watch Watch App
//
//  Created by Stepan Polyakov on 08.04.2025.
//

import Foundation
import WatchConnectivity
import SwiftUI

final class WatchDataManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchDataManager()
    
    @Published var currentUID: String = ""
    @Published var workouts: [Workout] = []
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        updateData(from: message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        updateData(from: applicationContext)
    }
    
    private func updateData(from dict: [String: Any]) {
        DispatchQueue.main.async {
            print("Тренировки получил")

            self.currentUID = dict["uid"] as? String ?? "no-uid"
            
            if let workoutsData = dict["workouts"] as? Data,
               let decoded = try? JSONDecoder().decode([Workout].self, from: workoutsData) {
                self.workouts = decoded
            } else {
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activated: \(activationState.rawValue), error: \(String(describing: error))")
    }
    
}
