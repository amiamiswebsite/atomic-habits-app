import SwiftData
import SwiftUI

enum PreviewHelpers {
    @MainActor
    static var container: ModelContainer {
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
            HabitSchedule.self,
            HabitReminder.self,
            HabitNote.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        for habit in SampleData.habits {
            container.mainContext.insert(habit)
        }
        return container
    }
}

#Preview("Onboarding") {
    OnboardingView()
        .modelContainer(PreviewHelpers.container)
}

#Preview("Today Active") {
    NavigationStack {
        TodayView()
    }
    .modelContainer(PreviewHelpers.container)
}

#Preview("Today Large Type") {
    NavigationStack {
        TodayView()
    }
    .environment(\.dynamicTypeSize, .accessibility3)
    .modelContainer(PreviewHelpers.container)
}

#Preview("Today Dark") {
    NavigationStack {
        TodayView()
    }
    .preferredColorScheme(.dark)
    .modelContainer(PreviewHelpers.container)
}

#Preview("Habit Detail") {
    NavigationStack {
        HabitDetailView(habit: SampleData.habits[0])
    }
    .modelContainer(PreviewHelpers.container)
}
