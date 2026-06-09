import HabitVotesCore
import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    @State private var showVoteFeedback = false
    @State private var completedHabitID: UUID?

    private var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    private var todayProgress: DayProgress {
        HabitProgressCalculator().dailyProgress(
            habits: activeHabits.map { ($0.scheduleSnapshot, $0.completionSnapshots) },
            on: .now
        )
    }

    private var nextHabit: Habit? {
        activeHabits.first { !$0.isCompleted(on: .now) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header

                if let nextHabit {
                    nextHabitSection(nextHabit)
                } else {
                    completionState
                }

                if activeHabits.count > 1 {
                    otherHabits
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .navigationTitle("Today")
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .overlay(alignment: .top) {
            if showVoteFeedback {
                IdentityVoteBadge(text: "+1 identity vote")
                    .padding(.top, DesignTokens.Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onAppear {
            WidgetSnapshotWriter.write(habits: habits)
        }
    }

    private var header: some View {
        GlassHabitCard {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Proof for today")
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Every small action becomes visible proof of who you are becoming.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: DesignTokens.Spacing.md)
                HabitProgressRing(
                    progress: todayProgress.rate,
                    completed: todayProgress.completed,
                    total: max(todayProgress.scheduled, activeHabits.count)
                )
                .frame(width: 116)
            }
        }
    }

    @ViewBuilder
    private func nextHabitSection(_ habit: Habit) -> some View {
        let recoveryState = RecoveryModeResolver().state(completions: habit.completionSnapshots, schedule: habit.scheduleSnapshot)

        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Next")
                .font(.title3.weight(.semibold))

            GlassHabitCard {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    habitSummary(habit)

                    if recoveryState != .none {
                        RecoveryPromptCard(
                            twoMinuteVersion: habit.twoMinuteVersion,
                            emphasized: recoveryState.isEmphasized
                        ) {
                            complete(habit, status: .recovered)
                        }
                    }

                    VStack(spacing: DesignTokens.Spacing.sm) {
                        PrimaryCTAButton(title: "Done", systemImage: "checkmark") {
                            complete(habit, status: .completed)
                        }
                        SecondaryButton(title: "2-minute version", systemImage: "timer") {
                            complete(habit, status: .miniCompleted)
                        }
                    }
                }
            }
            .scaleEffect(completedHabitID == habit.id && !reduceMotion ? 1.015 : 1)
            .animation(.spring(duration: 0.42, bounce: 0.18), value: completedHabitID)

            NavigationLink {
                HabitDetailView(habit: habit)
            } label: {
                Label("View details", systemImage: "chart.xyaxis.line")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderless)
        }
    }

    private func habitSummary(_ habit: Habit) -> some View {
        let summary = StreakCalculator().summary(completions: habit.completionSnapshots, schedule: habit.scheduleSnapshot)
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(habit.title)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                IdentityVoteBadge(text: "\(summary.current) streak", systemImage: "flame.fill")
            }

            Text(habit.identityStatement)
                .font(.body.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Label(habit.cueDescription, systemImage: "link")
                Label(habit.twoMinuteVersion, systemImage: "timer")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var completionState: some View {
        EmptyStateView(
            title: "Today has proof.",
            message: "All habits are complete. Let the win stay quiet and real.",
            systemImage: "checkmark.seal.fill"
        )
    }

    private var otherHabits: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("All habits")
                .font(.title3.weight(.semibold))
            ForEach(activeHabits) { habit in
                NavigationLink {
                    HabitDetailView(habit: habit)
                } label: {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        Image(systemName: habit.isCompleted(on: .now) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(habit.isCompleted(on: .now) ? AppTheme.success : .secondary)
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                            Text(habit.title)
                                .font(.headline)
                            Text(habit.cueDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func complete(_ habit: Habit, status: HabitCompletionStatus) {
        guard !habit.isCompleted(on: .now) else { return }
        let completion = HabitCompletion(habitId: habit.id, status: status)
        completion.habit = habit
        modelContext.insert(completion)

        do {
            try modelContext.save()
            AppHaptics.completion()
            WidgetSnapshotWriter.write(habits: habits)
            completedHabitID = habit.id
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) {
                showVoteFeedback = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
                withAnimation(reduceMotion ? nil : .easeIn(duration: 0.18)) {
                    showVoteFeedback = false
                    completedHabitID = nil
                }
            }
        } catch {
            modelContext.delete(completion)
        }
    }
}

private extension RecoveryModeState {
    var isEmphasized: Bool {
        if case .emphasized = self { return true }
        return false
    }
}
