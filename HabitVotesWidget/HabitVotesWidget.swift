import AppIntents
import SwiftUI
import WidgetKit

struct HabitVotesEntry: TimelineEntry {
    var date: Date
    var completed: Int
    var scheduled: Int
    var nextHabitTitle: String
    var nextHabitAction: String
}

struct HabitVotesProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitVotesEntry {
        HabitVotesEntry(date: .now, completed: 1, scheduled: 2, nextHabitTitle: "Read one page", nextHabitAction: "Read one paragraph")
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitVotesEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitVotesEntry>) -> Void) {
        completion(Timeline(entries: [entry()], policy: .after(.now.addingTimeInterval(15 * 60))))
    }

    private func entry() -> HabitVotesEntry {
        let defaults = UserDefaults(suiteName: "group.com.example.HabitVotes") ?? .standard
        return HabitVotesEntry(
            date: defaults.object(forKey: "snapshotDate") as? Date ?? .now,
            completed: defaults.integer(forKey: "todayCompleted"),
            scheduled: max(defaults.integer(forKey: "todayScheduled"), 1),
            nextHabitTitle: defaults.string(forKey: "nextHabitTitle") ?? "Create a habit",
            nextHabitAction: defaults.string(forKey: "nextHabitAction") ?? "Add one small vote"
        )
    }
}

struct HabitVotesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "HabitVotesWidget", provider: HabitVotesProvider()) { entry in
            HabitVotesWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("HabitVotes")
        .description("Today progress and your next small action.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HabitVotesWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: HabitVotesEntry

    private var progress: Double {
        guard entry.scheduled > 0 else { return 0 }
        return Double(entry.completed) / Double(entry.scheduled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("HabitVotes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(entry.completed)/\(entry.scheduled)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }

            ProgressView(value: progress)
                .tint(.accentColor)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.nextHabitTitle)
                    .font(family == .systemSmall ? .headline : .title3.weight(.semibold))
                    .lineLimit(2)
                Text(entry.nextHabitAction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(family == .systemSmall ? 2 : 3)
            }

            Spacer(minLength: 0)

            Button(intent: CompleteNextHabitIntent()) {
                Label("+1 vote", systemImage: "checkmark")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HabitVotes widget")
        .accessibilityValue("\(entry.completed) of \(entry.scheduled) habits complete. Next: \(entry.nextHabitTitle)")
    }
}
