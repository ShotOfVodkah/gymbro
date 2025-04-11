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
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("activated")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        updateData(from: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        updateData(from: message)
        replyHandler(["status": "success"])
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        updateData(from: applicationContext)
    }
    
    private func updateData(from dict: [String: Any]) {
        DispatchQueue.main.async {
            
            self.currentUID = dict["uid"] as? String ?? ""
            
            if let workoutsData = dict["workouts"] as? Data {
                do {
                    let decoded = try JSONDecoder().decode([Workout].self, from: workoutsData)
                    self.workouts = decoded
                    print("Получено \(decoded.count) workouts")
                } catch {
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendCompletedWorkout(_ workout: Workout) {
        guard WCSession.default.isReachable else {
            return
        }
          
        do {
              
            let encodedData = try JSONEncoder().encode(workout)
            let message: [String: Any] = [
                "type": "completedWorkout",
                "data": encodedData
            ]
            print("Encoded")
            WCSession.default.sendMessage(message, replyHandler: { _ in
                print("Workout sent successfully")
            }, errorHandler: { error in
                print("Send error: \(error.localizedDescription)")
            })
        } catch {
            print("Encoding error: \(error.localizedDescription)")
        }
    }
}

