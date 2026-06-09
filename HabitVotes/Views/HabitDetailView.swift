import HabitVotesCore
import SwiftData
import SwiftUI

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showsEdit = false
    @State private var showsArchiveConfirmation = false

    var habit: Habit

    private var summary: StreakSummary {
        StreakCalculator().summary(completions: habit.completionSnapshots, schedule: habit.scheduleSnapshot)
    }

    private var weeklyRate: Double {
        HabitProgressCalculator().weeklyCompletionRate(completions: habit.completionSnapshots, schedule: habit.scheduleSnapshot)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                GlassHabitCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        IdentityVoteBadge(text: "\(summary.totalVotes) identity votes")
                        Text(habit.title)
                            .font(.largeTitle.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(habit.identityStatement)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                        Label(habit.cueDescription, systemImage: "link")
                            .foregroundStyle(.secondary)
                    }
                }

                statsGrid

                GlassHabitCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        Text("Last 35 days")
                            .font(.headline.weight(.semibold))
                        HabitHeatmap(completions: habit.completionSnapshots)
                    }
                }

                GlassHabitCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        Text("This week")
                            .font(.headline.weight(.semibold))
                        WeeklyProgressChart(days: weeklyDays)
                    }
                }

                notesSection
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Habit")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showsEdit = true
                }
            }
        }
        .sheet(isPresented: $showsEdit) {
            NavigationStack {
                HabitEditView(mode: .edit(habit))
            }
        }
        .confirmationDialog("Archive this habit?", isPresented: $showsArchiveConfirmation, titleVisibility: .visible) {
            Button("Archive habit", role: .destructive) {
                habit.archivedAt = .now
                try? modelContext.save()
                WidgetSnapshotWriter.write(habits: [habit])
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Archived habits stop appearing on Today. Their history remains in the local store.")
        }
    }

    private var statsGrid: some View {
        Grid(horizontalSpacing: DesignTokens.Spacing.md, verticalSpacing: DesignTokens.Spacing.md) {
            GridRow {
                stat(title: "Current", value: "\(summary.current)", caption: "streak")
                stat(title: "Best", value: "\(summary.best)", caption: "streak")
            }
            GridRow {
                stat(title: "Votes", value: "\(summary.totalVotes)", caption: "total")
                stat(title: "Week", value: weeklyRate.formatted(.percent.precision(.fractionLength(0))), caption: "complete")
            }
        }
    }

    private func stat(title: String, value: String, caption: String) -> some View {
        GlassHabitCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title.bold())
                    .minimumScaleFactor(0.75)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notesSection: some View {
        GlassHabitCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                HStack {
                    Text("Notes")
                        .font(.headline.weight(.semibold))
                    Spacer()
                    Button(role: .destructive) {
                        showsArchiveConfirmation = true
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .font(.caption.weight(.semibold))
                }

                if habit.notes.isEmpty {
                    Text("Completion notes will appear here as the habit grows.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(habit.notes.sorted(by: { $0.createdAt > $1.createdAt })) { note in
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(note.body)
                            Text(note.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var weeklyDays: [DayProgress] {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: .now) else {
            return []
        }
        return (0..<7).compactMap { offset in
            guard let day = Calendar.current.date(byAdding: .day, value: offset, to: interval.start) else { return nil }
            let scheduled = ScheduleResolver().isScheduled(on: day, schedule: habit.scheduleSnapshot) ? 1 : 0
            let completed = habit.isCompleted(on: day) ? 1 : 0
            return DayProgress(date: day, completed: completed, scheduled: scheduled)
        }
    }
}
