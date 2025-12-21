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
        let defaults = UserDefaults(suiteName: "group.com.example.camwidget2")

        let appearance: CamWidgetAppearance
        if let data = defaults?.data(forKey: "widgetAppearance"),
           let decoded = try? JSONDecoder().decode(CamWidgetAppearance.self, from: data) {
            appearance = decoded
        } else {
            appearance = CamWidgetAppearance.default
        }

        return CamEntry(msg: "love u", date: .now, appearance: appearance)
    }

}


// MARK: - Widget View

struct CamWidgetView: View {
    let entry: CamEntry

    var body: some View {
        VStack(spacing: 8) {
            Text(entry.msg)
                .font(.caption)
                .foregroundColor(entry.appearance.accentColor.color)
                .multilineTextAlignment(.center)

            Text("\(daysRemaining)")
                .font(daysFont)
                .foregroundColor(entry.appearance.accentColor.color)
                .multilineTextAlignment(.center)


            Text("days left until we see each other")
                .font(.caption2)
                .foregroundColor(entry.appearance.accentColor.color.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(entry.appearance.backgroundTint.color)
        )
    }

    // MARK: - Calculate remaining days
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let target = calendar.startOfDay(for: entry.date)
        return max(calendar.dateComponents([.day], from: today, to: target).day ?? 0, 0)
    }

    // MARK: - Dynamic font based on style
    private var daysFont: Font {
        switch entry.appearance.fontStyle {
        case .regular: return .system(size: 42, weight: .bold)
        case .rounded: return .system(size: 42, weight: .bold, design: .rounded)
        case .serif: return .system(size: 42, weight: .bold, design: .serif)
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
        .configurationDisplayName("CamTime")
        .description("")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
