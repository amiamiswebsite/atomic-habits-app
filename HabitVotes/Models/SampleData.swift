import Foundation
import HabitVotesCore

enum SampleData {
    @MainActor
    static var habits: [Habit] {
        let read = Habit(
            title: "Read one page",
            identityStatement: "I am someone who keeps learning.",
            twoMinuteVersion: "Read one paragraph",
            cueDescription: "After coffee",
            schedule: HabitSchedule(cadence: .daily),
            reminder: HabitReminder(isEnabled: true, reminderMinutes: [8 * 60 + 30]),
            rewardStyle: .grounded,
            sortOrder: 0
        )
        read.completions = [
            HabitCompletion(habitId: read.id, date: Date().addingTimeInterval(-86_400 * 2), status: .completed),
            HabitCompletion(habitId: read.id, date: Date().addingTimeInterval(-86_400), status: .miniCompleted)
        ]

        let walk = Habit(
            title: "Walk outside",
            identityStatement: "I am a person who protects my energy.",
            twoMinuteVersion: "Step outside for two minutes",
            cueDescription: "After lunch",
            schedule: HabitSchedule(cadence: .daily),
            rewardStyle: .quiet,
            sortOrder: 1
        )

        return [read, walk]
    }
}
