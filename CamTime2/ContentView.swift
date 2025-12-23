import SwiftUI
import FirebaseFirestore
import WidgetKit

struct ContentView: View {

    // MARK: - State

    @State private var firebaseMessage: String = "No message yet"
    @State private var firebaseResponse: String = ""
    @State private var editedResponse: String = ""
    @State private var firebaseDate: Date? = nil

    @State private var isFetching = false
    @State private var isSaving = false

    // MARK: - UI

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.35),
                    Color.pink.opacity(0.15),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                mainCard
            }
            .padding()
        }
        .onAppear {
            startFirebaseListener(
                onUpdate: updateUI(message:targetDate:response:)
            )
        }
    }

    private var mainCard: some View {
        VStack(spacing: 20) {

            // Title
            Text("CamTime2")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.pink)

            // Message
            Text(firebaseMessage)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text("Message : " + firebaseResponse)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            // Countdown
            if let days = daysRemaining {
                VStack(spacing: 6) {
                    Text("\(days)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)

                    Text("days to go")
                        .font(.headline)
                        .foregroundColor(.pink.opacity(0.8))

                    Text("until we meet again")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }

            // Response field
            TextField("Write your response…", text: $editedResponse)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.pink.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                )

            // Send response button
            Button {
                saveResponseToFirebase()
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Send response 💕")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.pink,
                            Color.pink.opacity(0.7)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: .pink.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            .disabled(
                editedResponse == firebaseResponse ||
                editedResponse.isEmpty ||
                isSaving
            )
            .opacity(
                editedResponse == firebaseResponse || editedResponse.isEmpty ? 0.6 : 1
            )

            // Force fetch (debug)
            Button {
                forceFetchOnce()
            } label: {
                if isFetching {
                    ProgressView()
                } else {
                    Text("Force refresh")
                        .font(.footnote)
                        .foregroundColor(.pink)
                }
            }
            .disabled(isFetching)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.85))
                .shadow(color: .pink.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - UI Update

    @MainActor
    private func updateUI(message: String, targetDate: Date, response: String) {
        firebaseMessage = message
        firebaseDate = targetDate
        firebaseResponse = response
        editedResponse = response
    }

    // MARK: - Firebase Reads

    func forceFetchOnce() {
        let db = Firestore.firestore()
        isFetching = true

        db.collection("widget")
            .document("config")
            .getDocument { snapshot, error in
                DispatchQueue.main.async {
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

                guard let targetDate = formatter.date(from: targetDateStr) else { return }

                DispatchQueue.main.async {
                    updateUI(
                        message: message,
                        targetDate: targetDate,
                        response: response
                    )
                }
            }
    }

    // MARK: - Firebase Writes

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

    // MARK: - Date Logic

    private var daysRemaining: Int? {
        guard let targetDate = firebaseDate else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)

        let components = calendar.dateComponents([.day], from: today, to: target)
        return max(components.day ?? 0, 0)
    }
}

// MARK: - Firebase Listener (Shared)

private var listener: ListenerRegistration?

func startFirebaseListener(
    onUpdate: @escaping @MainActor (_ message: String, _ targetDate: Date, _ response: String) -> Void
) {
    let db = Firestore.firestore()

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

            Task { @MainActor in
                onUpdate(message, targetDate, response)

                let shared = CamSharedData(
                    message: message,
                    targetDate: targetDate,
                    response: response
                )

                let defaults = UserDefaults(
                    suiteName: "group.com.florent.camtime2"
                )

                if let encoded = try? JSONEncoder().encode(shared) {
                    defaults?.set(encoded, forKey: "camtime_data")
                    WidgetCenter.shared.reloadTimelines(
                                ofKind: "CamTimeWidget"
                            )
                }
            }
        }
}
