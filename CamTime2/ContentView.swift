import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Widget Demo App")
                .font(.title)

            Button("Update Widget") {
                saveWidgetAppearance()
            }
        }
        .padding()
    }

    private func saveWidgetAppearance() {
        let defaults = UserDefaults(suiteName: "group.com.example.camwidget2")

        let appearance = CamWidgetAppearance(
            backgroundStyle: .system,
            accentColor: "pink",
            fontStyle: .rounded
        )

        if let data = try? JSONEncoder().encode(appearance) {
            defaults?.set(data, forKey: "widgetAppearance")
        }

        // Ask WidgetKit to reload timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
}
