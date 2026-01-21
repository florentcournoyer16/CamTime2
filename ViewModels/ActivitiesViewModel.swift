import Foundation
internal import Combine


@MainActor
final class ActivitiesViewModel: ObservableObject {

    @Published private(set) var activities: [Activity] = []
    @Published var newActivityTitle = ""

    func start() {
        FirebaseActivitiesService.shared.startListening { [weak self] activities in
            DispatchQueue.main.async {
                self?.activities = activities
            }
        }
    }
    
    func updateTitle(_ activity: Activity, newTitle: String) {
        guard !newTitle.isEmpty else { return }

        FirebaseActivitiesService.shared.updateTitle(
            id: activity.id,
            title: newTitle
        )
    }

    func addActivity() {
        guard !newActivityTitle.isEmpty else { return }
        FirebaseActivitiesService.shared.addActivity(title: newActivityTitle)
        newActivityTitle = ""
    }

    func toggle(_ activity: Activity) {
        FirebaseActivitiesService.shared.updateCompletion(
            id: activity.id,
            completed: !activity.isCompleted
        )
    }

    func delete(at offsets: IndexSet) {
        offsets
            .map { activities[$0] }
            .forEach { FirebaseActivitiesService.shared.deleteActivity(id: $0.id) }
    }
}
