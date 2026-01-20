import Foundation
internal import Combine


@MainActor
final class CamTimeViewModel: ObservableObject {

    @Published private(set) var data: CamTimeData?
    @Published var editedResponse: String = ""

    @Published var isFetching = false
    @Published var isSaving = false


    // MARK: - Lifecycle

    func start() {
        FirebaseCamTimeService.shared.startListening { [weak self] data in
            self?.apply(data)
        }
    }

    
    // MARK: - Actions

    func forceRefresh() {
        isFetching = true

        FirebaseCamTimeService.shared.fetchOnce { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetching = false

                if case .success(let data) = result {
                    self?.apply(data)
                }
            }
        }
    }

    func saveResponse() {
        guard let data else { return }

        isSaving = true

        FirebaseCamTimeService.shared.updateResponse(editedResponse) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isSaving = false
            }
        }
    }

    
    // MARK: - Derived State

    var daysRemaining: Int? {
        guard let targetDate = data?.targetDate else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)

        return max(
            calendar.dateComponents([.day], from: today, to: target).day ?? 0,
            0
        )
    }

    var canSendResponse: Bool {
        guard let data else { return false }

        return editedResponse != data.response &&
               !editedResponse.isEmpty &&
               !isSaving
    }

    
    // MARK: - Private

    private func apply(_ data: CamTimeData) {
        self.data = data
        self.editedResponse = data.response
    }
}
