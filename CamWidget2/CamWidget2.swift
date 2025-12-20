import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let daysRemaining: Int
    let message: String
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), daysRemaining: 5, message: "Soon ❤️")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(SimpleEntry(date: Date(), daysRemaining: 5, message: "Soon ❤️"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), daysRemaining: 5, message: "Soon ❤️")

        // Update every 1 minute for demo purposes
        let nextUpdate = Date().addingTimeInterval(60)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct CamWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text("Days days left")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(entry.daysRemaining)")
                .font(.system(size: 32, weight: .bold))
            Text(entry.daysRemaining == 1 ? "jour" : "jours")
                .font(.headline)
            Text(entry.message)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

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

#Preview(as: .systemSmall) {
    CamWidget2()
} timeline: {
    SimpleEntry(date: .now, daysRemaining: 5, message: "Love u ❤️")
}
