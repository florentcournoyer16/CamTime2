import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CamTimeEntry: TimelineEntry {
    let message: String
    let date: Date
}

// MARK: - Provider

struct CamTimeProvider: TimelineProvider {

    func placeholder(in context: Context) -> CamTimeEntry {
        CamTimeEntry(message: "I love u", date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CamTimeEntry) -> Void) {
        completion(CamTimeEntry(message: "I love u", date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CamTimeEntry>) -> Void) {

        // Date cible (à modifier)
        let targetDate = Calendar.current.date(
            from: DateComponents(year: 2025, month: 6, day: 1)
        )!

        let entry = CamTimeEntry(message: "I love u", date: targetDate)

        completion(
            Timeline(entries: [entry], policy: .never)
        )
    }
}

// MARK: - Widget View

struct CamTimeWidgetView: View {
    let entry: CamTimeEntry

    var body: some View {
        VStack(spacing: 8) {

            Text("love you")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 140)

            Text("\(daysRemaining)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("days to go")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            Text("until we meet again")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding()
        .containerBackground(
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.45),
                    Color.pink.opacity(0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
    }

    private var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: entry.date)

        let components = calendar.dateComponents([.day], from: today, to: target)
        return max(components.day ?? 0, 0)
    }
}


// MARK: - Widget

@main
struct CamTimeWidget: Widget {
    let kind = "CamTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CamTimeProvider()) { entry in
            CamTimeWidgetView(entry: entry)
        }
        .configurationDisplayName("CamTime")
        .description("Days until we see each other.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
