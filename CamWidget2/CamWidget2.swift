import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int
    let message: String
}

// MARK: - AccentColor

extension AccentColor {
    var color: Color {
        switch self {
        case .pink:  return .pink
        case .blue:  return .blue
        case .red:   return .red
        case .green: return .green
        }
    }
}


// MARK: - FontStyle
extension FontStyle {

    func numberFont(size: CGFloat) -> Font {
        switch self {
        case .regular:
            return .system(size: size, weight: .bold)

        case .rounded:
            return .system(size: size, weight: .bold, design: .rounded)

        case .serif:
            return .system(size: size, weight: .bold, design: .serif)

        case .handwritten:
            return .system(size: size, weight: .medium, design: .rounded)
                .italic()

        case .handwrittenBold:
            return .system(size: size, weight: .bold, design: .rounded)
                .italic()
        }
    }

    var labelFont: Font {
        switch self {
        case .handwritten, .handwrittenBold:
            return .callout.italic()
        case .serif:
            return .system(.headline, design: .serif)
        default:
            return .headline
        }
    }
}


// MARK: - Background style (widget-safe)

extension View {
    func applyBackgroundTint(_ tint: CodableColor) -> some View {
        self.overlay(
            tint.color
                .opacity(0.18)
                .blendMode(.softLight)
        )
    }
}



// MARK: - Timeline Provider

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), daysRemaining: 5, message: "Soon ❤️")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), daysRemaining: 5, message: "Soon ❤️"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {

        let entry = SimpleEntry(
            date: Date(),
            daysRemaining: 5,
            message: "Soon ❤️"
        )

        // Demo refresh every minute
        let nextUpdate = Date().addingTimeInterval(60)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget View

struct CamWidgetEntryView: View {
    var entry: Provider.Entry

    @AppStorage(
        "widgetAppearance",
        store: UserDefaults(suiteName: "group.com.example.camwidget2")
    )
    private var appearanceData: Data = Data()

    private var appearance: CamWidgetAppearance {
        if let decoded = try? JSONDecoder().decode(
            CamWidgetAppearance.self,
            from: appearanceData
        ) {
            return decoded
        }

        // Fallback (must always be safe)
        return CamWidgetAppearance(
            backgroundTint: CodableColor(
                    Color(red: 1.0, green: 0.95, blue: 0.97, opacity: 0.25)
                ),
            accentColor: .pink,
            fontStyle: .rounded
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            
            Text("\(entry.daysRemaining)")
                .font(appearance.fontStyle.numberFont(size: 40))
                .foregroundStyle(
                    appearance.accentColor.color.opacity(0.85)
                )
            
            Text(entry.message)
                .font(.caption)
                .foregroundStyle(.primary.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding()
        .applyBackgroundTint(appearance.backgroundTint)
    }
}

// MARK: - Widget Definition

@main
struct CamWidget2: Widget {
    let kind: String = "CamWidget2"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CamWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Countdown Widget")
        .description("Shows days remaining")
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    CamWidget2()
} timeline: {
    SimpleEntry(date: .now, daysRemaining: 5, message: "Love u ❤️")
}
