import SwiftUI
import FirebaseFirestore
import WidgetKit


struct ContentView: View {

    var body: some View {
        VStack {
            Text("CamTime")
        }
        .onAppear {
            startFirebaseListener()
        }
    }
}


private var listener: ListenerRegistration?

func startFirebaseListener() {
    let db = Firestore.firestore()

    listener = db.collection("camtime")
        .document("status")
        .addSnapshotListener { snapshot, error in

            guard
                let data = snapshot?.data(),
                let message = data["message"] as? String,
                let dateString = data["date"] as? String
            else { return }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            guard let date = formatter.date(from: dateString) else { return }

            // 🔁 Hop to MainActor
            Task { @MainActor in
                let shared = CamSharedData(
                    message: message,
                    targetDate: date
                )

                let defaults = UserDefaults(
                    suiteName: "group.com.tonnom.camtime"
                )

                if let encoded = try? JSONEncoder().encode(shared) {
                    defaults?.set(encoded, forKey: "camtime_data")

                    // 🚀 THIS updates the widget
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
}


