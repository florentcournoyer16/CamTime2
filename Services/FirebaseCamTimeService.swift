import FirebaseFirestore
import WidgetKit


final class FirebaseCamTimeService {

    static let shared = FirebaseCamTimeService()
    private init() {}

    private let db = Firestore.firestore()
    private let documentPath = ("widget", "config")

    private var listener: ListenerRegistration?


    // MARK: - Public API

    func startListening(
        onUpdate: @escaping @MainActor (CamTimeData) -> Void
    ) {
        listener = db
            .collection(documentPath.0)
            .document(documentPath.1)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("Firebase listener error:", error)
                    return
                }

                guard let data = self.parse(snapshot: snapshot) else {
                    print("Invalid Firebase data")
                    return
                }

                Task { @MainActor in
                    onUpdate(data)
                    self.updateWidget(with: data)
                }
            }
    }

    func fetchOnce(
        completion: @escaping (Result<CamTimeData, Error>) -> Void
    ) {
        db.collection(documentPath.0)
            .document(documentPath.1)
            .getDocument { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = self.parse(snapshot: snapshot) else {
                    completion(.failure(NSError()))
                    return
                }

                completion(.success(data))
            }
    }

    func updateResponse(_ response: String, completion: @escaping (Error?) -> Void) {
        db.collection(documentPath.0)
            .document(documentPath.1)
            .updateData(["response": response], completion: completion)
    }

    
    // MARK: - Helpers

    private func parse(snapshot: DocumentSnapshot?) -> CamTimeData? {
        guard
            let data = snapshot?.data(),
            let message = data["message"] as? String,
            let dateString = data["target_date"] as? String,
            let response = data["response"] as? String,
            let targetDate = Self.dateFormatter.date(from: dateString)
        else {
            return nil
        }

        return CamTimeData(
            message: message,
            targetDate: targetDate,
            response: response
        )
    }

    private func updateWidget(with data: CamTimeData) {
        let defaults = UserDefaults(
            suiteName: "group.com.florent.camtime2"
        )

        if let encoded = try? JSONEncoder().encode(data) {
            defaults?.set(encoded, forKey: "camtime_data")
            WidgetCenter.shared.reloadTimelines(ofKind: "CamTimeWidget")
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
