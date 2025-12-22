import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CamTimeEntry: TimelineEntry {
    let date: Date
    let targetDate: Date
    let message: String
}


// MARK: - Provider

struct CamTimeProvider: TimelineProvider {

    func placeholder(in context: Context) -> CamTimeEntry {
        CamTimeEntry(
            date: Date(),
            targetDate: Date(),
            message: "love you"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CamTimeEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CamTimeEntry>) -> Void) {
        let entry = loadEntry()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func loadEntry() -> CamTimeEntry {
        let defaults = UserDefaults(
            suiteName: "group.com.example.camtime2"
        )

        if
            let data = defaults?.data(forKey: "camtime_data"),
            let decoded = try? JSONDecoder().decode(CamSharedData.self, from: data)
        {
            print("Widget loaded new data")
            return CamTimeEntry(
                date: Date(),
                targetDate: decoded.targetDate,
                message: decoded.message
            )
        }

        return CamTimeEntry(
            date: Date(),
            targetDate: Date(),
            message: "love you"
        )
    }
}

// MARK: - Widget View

struct CamTimeWidgetView: View {
    let entry: CamTimeEntry

    var body: some View {
        VStack(spacing: 8) {

            Text(entry.message)
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
        let target = calendar.startOfDay(for: entry.targetDate)


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
