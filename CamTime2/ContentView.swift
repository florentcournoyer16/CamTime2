import SwiftUI
import FirebaseFirestore
import WidgetKit


struct ContentView: View {

    var body: some View {
        VStack {
            Text("CamTime2")
        }
        .onAppear {
            startFirebaseListener()
        }
    }
}


private var listener: ListenerRegistration?

func startFirebaseListener() {
    let db = Firestore.firestore()
    
    print("App begin")

    listener = db.collection("widget")
        .document("config")
        .addSnapshotListener { snapshot, error in

            guard
                let data = snapshot?.data(),
                let message = data["message"] as? String,
                let target_date_str = data["target_date"] as? String
            else { return }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            print("Firebase update received")

            guard let target_date = formatter.date(from: target_date_str) else { return }

            // 🔁 Hop to MainActor
            Task { @MainActor in
                let shared = CamSharedData(
                    message: message,
                    targetDate: target_date
                )

                let defaults = UserDefaults(
                    suiteName: "com.example.camtime2"
                )

                if let encoded = try? JSONEncoder().encode(shared) {
                    defaults?.set(encoded, forKey: "camtime_data")
                    print("Data encoded")

                    // 🚀 THIS updates the widget
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
}


