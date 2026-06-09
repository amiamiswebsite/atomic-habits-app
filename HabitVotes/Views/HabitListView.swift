import SwiftData
import SwiftUI

struct HabitListView: View {
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]
    @State private var showsNewHabit = false

    private var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    var body: some View {
        List {
            if activeHabits.isEmpty {
                EmptyStateView(title: "No active habits", message: "Create one small vote to begin again.", systemImage: "plus.circle")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(activeHabits) { habit in
                    NavigationLink {
                        HabitDetailView(habit: habit)
                    } label: {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(habit.title)
                                .font(.headline)
                            Text(habit.identityStatement)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, DesignTokens.Spacing.xs)
                    }
                }
            }
        }
        .navigationTitle("Habits")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showsNewHabit = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create habit")
            }
        }
        .sheet(isPresented: $showsNewHabit) {
            NavigationStack {
                HabitEditView(mode: .create)
            }
        }
    }
}
