import WatchConnectivity
import FirebaseAuth
import FirebaseFirestore
final class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    private var session = WCSession.default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func sendUserWorkouts(_ workouts: [Workout]) {
        guard session.isPaired, session.isWatchAppInstalled else { return }
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        guard let encoded = try? JSONEncoder().encode(workouts) else { return }
        print("Закодировано")
        let data: [String: Any] = [
            "uid": uid,
            "workouts": encoded
        ]
        
        if session.isReachable {
            session.sendMessage(data, replyHandler: nil)
            print("Отправлено")
        } else {
            try? session.updateApplicationContext(data)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Получено")
        DispatchQueue.global().async {
            if message["type"] as? String == "completedWorkout",
               let workoutData = message["data"] as? Data {
                do {
                    let workout = try JSONDecoder().decode(Workout.self, from: workoutData)

                    let db = Firestore.firestore()
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    saveWorkoutDone(workout: workout, comment: "")
                    let exercisesData = workout.exercises.map { exercise in
                        return [
                            "name": exercise.name,
                            "muscle_group": exercise.muscle_group,
                            "is_selected": exercise.is_selected,
                            "weight": exercise.weight,
                            "sets": exercise.sets,
                            "reps": exercise.reps
                        ]
                    }

                    db.collection("workouts").document(uid)
                        .collection("workouts_for_id").document(workout.id)
                        .setData([
                            "exercises": exercisesData,
                            "last_updated": FieldValue.serverTimestamp()
                        ], merge: true) { error in
                            if let error = error {
                                replyHandler(["status": "error", "message": error.localizedDescription])
                            } else {
                                replyHandler(["status": "success"])
                            }
                        }
                } catch {
                    print("Ошибка декодирования: \(error)")
                    replyHandler(["status": "decode_error"])
                }
            } else {
                replyHandler(["status": "invalid_data"])
            }
        }
    }

}
