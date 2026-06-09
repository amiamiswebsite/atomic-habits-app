import SwiftData
import SwiftUI

struct AppRootView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    var body: some View {
        Group {
            if habits.filter({ !$0.isArchived }).isEmpty {
                OnboardingView()
            } else {
                TabView {
                    NavigationStack {
                        TodayView()
                    }
                    .tabItem {
                        Label("Today", systemImage: "circle.hexagongrid.fill")
                    }

                    NavigationStack {
                        HabitListView()
                    }
                    .tabItem {
                        Label("Habits", systemImage: "list.bullet")
                    }
                }
            }
        }
        .tint(AppTheme.accent)
        .background(AppTheme.pageBackground)
        .onChange(of: habits.map(\.id)) {
            WidgetSnapshotWriter.write(habits: habits)
        }
    }
}
