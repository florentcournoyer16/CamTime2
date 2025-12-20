import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {

        WidgetAppearanceView()

    }
}


struct WidgetAppearanceView: View {


    @State private var accentColor: AccentColor = .pink
    @State private var fontStyle: FontStyle = .rounded
    @State private var backgroundColor: Color = .pink.opacity(0.2)

    var body: some View {
        Form {

            // Accent color
            Section("Accent color") {
                Picker("Accent color", selection: $accentColor) {
                    ForEach(AccentColor.allCases, id: \.self) { color in
                        Text(color.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Font
            Section("Font style") {
                Picker("Font style", selection: $fontStyle) {
                    ForEach(FontStyle.allCases, id: \.self) { font in
                        Text(font.rawValue.capitalized)
                    }
                }
            }

            // Background
            Section("Background") {
                
                ColorPicker("Background tint", selection: $backgroundColor, supportsOpacity: true)
            }

            // Apply button
            Button("Apply to Widget") {
                saveAppearance()
            }
            .font(.headline)
        }
        .navigationTitle("Widget Style")
    }

    private func saveAppearance() {

    
        let appearance = CamWidgetAppearance(
            backgroundTint: CodableColor(backgroundColor),
            accentColor: accentColor,
            fontStyle: fontStyle
        )
        

        let defaults = UserDefaults(suiteName: "group.com.example.camwidget2")

        if let data = try? JSONEncoder().encode(appearance) {
            defaults?.set(data, forKey: "widgetAppearance")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
