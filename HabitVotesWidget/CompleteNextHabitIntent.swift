import AppIntents
import WidgetKit

struct CompleteNextHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Next Habit"
    static var description = IntentDescription("Adds one visible identity vote from the widget snapshot.")

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.example.HabitVotes") ?? .standard
        let scheduled = max(defaults.integer(forKey: "todayScheduled"), 1)
        let completed = min(defaults.integer(forKey: "todayCompleted") + 1, scheduled)
        defaults.set(completed, forKey: "todayCompleted")
        if completed >= scheduled {
            defaults.set("All habits complete", forKey: "nextHabitTitle")
            defaults.set("Proof added for today.", forKey: "nextHabitAction")
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
