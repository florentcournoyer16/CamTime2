import FirebaseFirestore

final class FirebaseActivitiesService {

    static let shared = FirebaseActivitiesService()
    private init() {}

    private let db = Firestore.firestore()
    private let collection = "activities"

    private var listener: ListenerRegistration?

    
    // MARK: - Read

    func startListening(
        onUpdate: @escaping ([Activity]) -> Void
    ) {
        listener = db.collection(collection)
            .addSnapshotListener { snapshot, error in

                if let error = error {
                    print("Activities error:", error)
                    return
                }

                let activities = snapshot?.documents.compactMap {
                    self.parse(document: $0)
                } ?? []

                onUpdate(activities)
            }
    }


    
    // MARK: - Write

    func addActivity(title: String) {
        db.collection(collection).addDocument(data: [
            "title": title,
            "completed": false
        ])
    }

    func updateCompletion(id: String, completed: Bool) {
        db.collection(collection)
            .document(id)
            .updateData(["completed": completed])
    }

    func deleteActivity(id: String) {
        db.collection(collection)
            .document(id)
            .delete()
    }
    
    func updateTitle(id: String, title: String) {
        db.collection(collection)
            .document(id)
            .updateData(["title": title])
    }
    
    



    
    // MARK: - Helper

    private func parse(document: QueryDocumentSnapshot) -> Activity? {
        let data = document.data()

        guard
            let title = data["title"] as? String,
            let completed = data["completed"] as? Bool
        else { return nil }

        return Activity(
            id: document.documentID,
            title: title,
            isCompleted: completed
        )
    }
}
