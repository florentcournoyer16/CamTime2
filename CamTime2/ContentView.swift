import SwiftUI
import FirebaseFirestore
import WidgetKit


struct ContentView: View {

    @State private var firebaseMessage: String = "No message yet"
    @State private var firebaseResponse: String = "No response yet"
    @State private var editedResponse: String = ""
    @State private var firebaseDate: Date? = nil
    @State private var isFetching = false
    @State private var isSaving = false

    var body: some View {
        
        

        VStack(spacing: 16) {

            Text("CamTime2")
                .font(.title)
    
            Text(firebaseMessage)
                .font(.subheadline)
            
            if let days = daysRemaining {
                VStack(spacing: 4) {
                    Text("\(days)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    Text("days to go")
                        .font(.headline)

                    Text("until we meet again")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            TextField("Write your response…", text: $editedResponse)
                   .textFieldStyle(.roundedBorder)

            Button {
                   saveResponseToFirebase()
               } label: {
                   if isSaving {
                       ProgressView()
                   } else {
                       Text("Send response")
                   }
               }
               .disabled(
                   editedResponse == firebaseResponse ||
                   editedResponse.isEmpty ||
                   isSaving
               )

            Button {
                forceFetchOnce()
            } label: {
                if isFetching {
                    ProgressView()
                } else {
                    Text("Force fetch from Firebase")
                }
            }
            .disabled(isFetching)
        }
        .padding()
        .onAppear {
            startFirebaseListener(
                onUpdate: updateUI(message:targetDate:response:)
            )
        }
    }

    @MainActor
    private func updateUI(message: String, targetDate: Date, response: String) {
        self.firebaseMessage = message
        self.firebaseDate = targetDate
        self.firebaseResponse = response
    }

    
    func forceFetchOnce() {
        let db = Firestore.firestore()

        Task { @MainActor in
            isFetching = true
        }

        db.collection("widget")
            .document("config")
            .getDocument { snapshot, error in

                Task { @MainActor in
                    isFetching = false
                }

                if let error = error {
                    print("Force fetch error:", error)
                    return
                }

                guard
                    let data = snapshot?.data(),
                    let message = data["message"] as? String,
                    let targetDateStr = data["target_date"] as? String,
                    let response = data["response"] as? String
                else {
                    print("Invalid Firebase data")
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"

                guard let targetDate = formatter.date(from: targetDateStr) else {
                    return
                }

                Task { @MainActor in
                    updateUI(message: message, targetDate: targetDate, response: response)
                }
            }
    }
    
    private var daysRemaining: Int? {
        guard let targetDate = firebaseDate else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)

        let components = calendar.dateComponents([.day], from: today, to: target)
        return max(components.day ?? 0, 0)
    }
    
    
    func saveResponseToFirebase() {
        let db = Firestore.firestore()

        isSaving = true

        db.collection("widget")
            .document("config")
            .updateData([
                "response": editedResponse
            ]) { error in

                DispatchQueue.main.async {
                    isSaving = false
                }

                if let error = error {
                    print("Failed to update response:", error)
                } else {
                    print("Response successfully updated")
                }
            }
    }




}



private var listener: ListenerRegistration?
func startFirebaseListener(
    onUpdate: @escaping @MainActor (_ message: String, _ targetDate: Date, _ response: String) -> Void
) {
    let db = Firestore.firestore()

    print("App begin")

    listener = db.collection("widget")
        .document("config")
        .addSnapshotListener { snapshot, error in

            if let error = error {
                print("Firebase error:", error)
                return
            }

            guard
                let data = snapshot?.data(),
                let message = data["message"] as? String,
                let targetDateStr = data["target_date"] as? String,
                let response = data["response"] as? String
            else {
                print("Invalid Firebase data")
                return
            }


            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            guard let targetDate = formatter.date(from: targetDateStr) else {
                print("Invalid date format")
                return
            }

            print("Firebase update received:", message)

            Task { @MainActor in
                // Update app UI
                onUpdate(message, targetDate, response)

                // Update shared widget data
                let shared = CamSharedData(
                    message: message,
                    targetDate: targetDate,
                    response: response
                )


                let defaults = UserDefaults(
                    suiteName: "group.com.example.camtime2"
                )

                if let encoded = try? JSONEncoder().encode(shared) {
                    defaults?.set(encoded, forKey: "camtime_data")
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
}
