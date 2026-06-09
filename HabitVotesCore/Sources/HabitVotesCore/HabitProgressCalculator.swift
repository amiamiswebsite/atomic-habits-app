import Foundation

public struct DayProgress: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public var date: Date
    public var completed: Int
    public var scheduled: Int

    public init(date: Date, completed: Int, scheduled: Int) {
        self.date = date
        self.completed = completed
        self.scheduled = scheduled
    }

    public var rate: Double {
        guard scheduled > 0 else { return 0 }
        return Double(completed) / Double(scheduled)
    }
}

public struct HabitProgressCalculator: Sendable {
    private let scheduleResolver: ScheduleResolver

    public init(scheduleResolver: ScheduleResolver = ScheduleResolver()) {
        self.scheduleResolver = scheduleResolver
    }

    public func weeklyCompletionRate(
        completions: [HabitCompletionSnapshot],
        schedule: HabitScheduleSnapshot,
        weekContaining date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> Double {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return 0
        }

        let end = calendar.date(byAdding: .day, value: 6, to: interval.start) ?? interval.start
        let scheduledDays = scheduleResolver.scheduledDates(
            from: interval.start,
            through: end,
            schedule: schedule,
            calendar: calendar
        )

        guard !scheduledDays.isEmpty else { return 0 }

        let completedDays = scheduledDays.filter { day in
            completions.contains {
                calendar.isDate($0.date, inSameDayAs: day) && $0.status.keepsHabitAlive
            }
        }

        return Double(completedDays.count) / Double(scheduledDays.count)
    }

    public func dailyProgress(
        habits: [(schedule: HabitScheduleSnapshot, completions: [HabitCompletionSnapshot])],
        on date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> DayProgress {
        let scheduledHabits = habits.filter {
            scheduleResolver.isScheduled(on: date, schedule: $0.schedule, calendar: calendar)
        }
        let completedHabits = scheduledHabits.filter { habit in
            habit.completions.contains {
                calendar.isDate($0.date, inSameDayAs: date) && $0.status.keepsHabitAlive
            }
        }

        return DayProgress(date: calendar.startOfDay(for: date), completed: completedHabits.count, scheduled: scheduledHabits.count)
    }
}
