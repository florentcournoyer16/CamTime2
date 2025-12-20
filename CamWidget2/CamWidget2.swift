import WidgetKit
import SwiftUI

// MARK: - Entry

struct CamEntry: TimelineEntry {
    let msg: String
    let date: Date
    let appearance: CamWidgetAppearance
}

// MARK: - Provider

struct CamProvider: TimelineProvider {

    func placeholder(in context: Context) -> CamEntry {
        CamEntry(msg: "love u", date: .now, appearance: .default)
    }

    func getSnapshot(in context: Context, completion: @escaping (CamEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CamEntry>) -> Void) {
        let entry = loadEntry()
        completion(
            Timeline(entries: [entry], policy: .atEnd)
        )
    }

    private func loadEntry() -> CamEntry {
        let defaults = UserDefaults(
            suiteName: "group.com.example.camwidget2"
        )

        let appearance =
            if let data = defaults?.data(forKey: "widgetAppearance"),
               let decoded = try? JSONDecoder().decode(
                    CamWidgetAppearance.self,
                    from: data
               ) {
                decoded
            } else {
                CamWidgetAppearance.default
            }

        return CamEntry(msg: "love u", date: .now, appearance: appearance)
    }
}

// MARK: - Widget View

struct CamWidgetView: View {
    let entry: CamEntry

    var body: some View {
        VStack(spacing: 6) {

            Text(entry.msg)
                .font(.caption)
                .foregroundColor(entry.appearance.accentColor.color)
                .multilineTextAlignment(.center)

            Text("\(daysRemaining)")
                .font(daysFont)
                .foregroundColor(entry.appearance.accentColor.color)
                .minimumScaleFactor(0.5)

            Text("days left until we see each other")
                .font(.caption2)
                .foregroundColor(entry.appearance.accentColor.color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .containerBackground(
            entry.appearance.backgroundTint.color,
            for: .widget
        )
    }

    // MARK: - Date logic

    private var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTarget = calendar.startOfDay(for: entry.date)

        let components = calendar.dateComponents(
            [.day],
            from: startOfToday,
            to: startOfTarget
        )

        return max(components.day ?? 0, 0)
    }

    // MARK: - Font logic

    private var daysFont: Font {
        switch entry.appearance.fontStyle {
        case .regular:
            return .system(size: 42, weight: .bold)
        case .rounded:
            return .system(size: 42, weight: .bold, design: .rounded)
        case .serif:
            return .system(size: 42, weight: .bold, design: .serif)
        }
    }
}


// MARK: - Widget

@main
struct CamWidget: Widget {
    let kind = "CamWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CamProvider()
        ) { entry in
            CamWidgetView(entry: entry)
        }
        .configurationDisplayName("CamTime Widget")
        .description("Displays CamTime with custom style.")
        .supportedFamilies([.systemSmall])
    }
}
