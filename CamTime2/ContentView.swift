import SwiftUI
import WidgetKit

struct ContentView: View {

    @State private var accentColor: Color = .black.opacity(0.9)
    @State private var fontStyle: FontStyle = .rounded
    @State private var backgroundColor: Color = .pink.opacity(0.2)

    var body: some View {
        NavigationStack {
            Form {
                
                Section("Font style") {
                    Picker("Font style", selection: $fontStyle) {
                        ForEach(FontStyle.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }

                Section("Accent color") {
                        ColorPicker(
                            "Accent color",
                            selection: $accentColor,
                            supportsOpacity: true
                        )
                }



                Section("Background") {
                    ColorPicker(
                        "Background tint",
                        selection: $backgroundColor,
                        supportsOpacity: true
                    )
                }
                
                Button("Romantic") {
                    backgroundColor = .pink.opacity(0.2)
                    accentColor = .red
                    fontStyle = .rounded
                    saveAppearance()
                }


                Button("Apply to Widget") {
                    saveAppearance()
                }
                .font(.headline)
            }
            .navigationTitle("Widget Style")
        }
    }

    private func saveAppearance() {
        let appearance = CamWidgetAppearance(
            backgroundTint: CodableColor(backgroundColor),
            accentColor: CodableColor(accentColor),
            fontStyle: fontStyle
        )

        let defaults = UserDefaults(
            suiteName: "group.com.example.camwidget2"
        )

        if let data = try? JSONEncoder().encode(appearance) {
            defaults?.set(data, forKey: "widgetAppearance")
            print("Saved appearance: \(appearance)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                WidgetCenter.shared.reloadTimelines(ofKind: "CamWidget")
            }
        }

    }
}
