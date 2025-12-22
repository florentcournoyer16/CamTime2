import SwiftUI
import Combine
import FirebaseFirestore


final class CamFirebaseViewModel: ObservableObject {

    
    @Published var message: String = "—"
    @Published var date: Date = .now

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        startListening()
    }

    private func startListening() {
        print("📡 [Firebase] Starting listener")

        listener = db
            .collection("camtime")
            .document("nextMeeting")
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("❌ [Firebase] Error:", error)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("⚠️ [Firebase] Snapshot empty")
                    return
                }

                print("✅ [Firebase] Data received:", data)

                if let msg = data["message"] as? String {
                    self.message = msg
                }

                if let timestamp = data["date"] as? Timestamp {
                    self.date = timestamp.dateValue()
                }
            }
    }

    deinit {
        listener?.remove()
        print("🧹 [Firebase] Listener removed")
    }
}
