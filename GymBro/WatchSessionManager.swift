import WatchConnectivity
import FirebaseAuth
final class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    private var session = WCSession.default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        } else {
            print("NOT supported")
        }
    }
    
    func sendUserWorkouts(_ workouts: [Workout]) {
        guard session.isPaired, session.isWatchAppInstalled else {
            return
        }

        let uid = Auth.auth().currentUser?.uid ?? "unknown"
        guard let encoded = try? JSONEncoder().encode(workouts) else {
            return
        }
        
        let data: [String: Any] = [
            "uid": uid,
            "workouts": encoded
        ]
        
        if session.isReachable {
            session.sendMessage(data, replyHandler: { _ in
            }, errorHandler: { error in
            })
        } else {
            do {
                try session.updateApplicationContext(data)
                print("Тренировки отправлены на apple watch")
            } catch {
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
