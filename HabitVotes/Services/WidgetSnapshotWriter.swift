import Foundation
import HabitVotesCore
import WidgetKit

enum WidgetSnapshotWriter {
    static let appGroupIdentifier = "group.com.example.HabitVotes"

    static func write(habits: [Habit], date: Date = Date(), calendar: Calendar = .habitVotesGregorian) {
        let activeHabits = habits.filter { !$0.isArchived }
        let progress = HabitProgressCalculator().dailyProgress(
            habits: activeHabits.map { ($0.scheduleSnapshot, $0.completionSnapshots) },
            on: date,
            calendar: calendar
        )
        let nextHabit = activeHabits.first { !$0.isCompleted(on: date, calendar: calendar) }
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        defaults.set(progress.completed, forKey: "todayCompleted")
        defaults.set(progress.scheduled, forKey: "todayScheduled")
        defaults.set(nextHabit?.title ?? "All habits complete", forKey: "nextHabitTitle")
        defaults.set(nextHabit?.twoMinuteVersion ?? "Rest in the proof you built today.", forKey: "nextHabitAction")
        defaults.set(date, forKey: "snapshotDate")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
