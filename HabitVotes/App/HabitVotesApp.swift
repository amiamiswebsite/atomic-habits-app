import SwiftData
import SwiftUI

@main
struct HabitVotesApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            Habit.self,
            HabitCompletion.self,
            HabitSchedule.self,
            HabitReminder.self,
            HabitNote.self
        ])
    }
}
