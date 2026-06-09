import Foundation

public struct StreakSummary: Equatable, Sendable {
    public var current: Int
    public var best: Int
    public var totalVotes: Int

    public init(current: Int, best: Int, totalVotes: Int) {
        self.current = current
        self.best = best
        self.totalVotes = totalVotes
    }
}

public struct StreakCalculator: Sendable {
    private let scheduleResolver: ScheduleResolver

    public init(scheduleResolver: ScheduleResolver = ScheduleResolver()) {
        self.scheduleResolver = scheduleResolver
    }

    public func summary(
        completions: [HabitCompletionSnapshot],
        schedule: HabitScheduleSnapshot,
        asOf date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> StreakSummary {
        StreakSummary(
            current: currentStreak(completions: completions, schedule: schedule, asOf: date, calendar: calendar),
            best: bestStreak(completions: completions, schedule: schedule, asOf: date, calendar: calendar),
            totalVotes: completions.reduce(0) { $0 + $1.status.identityVoteValue }
        )
    }

    public func currentStreak(
        completions: [HabitCompletionSnapshot],
        schedule: HabitScheduleSnapshot,
        asOf date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> Int {
        let statusByDay = keepAliveStatusByDay(completions: completions, calendar: calendar)
        let today = calendar.startOfDay(for: date)
        var cursor: Date?

        if scheduleResolver.isScheduled(on: today, schedule: schedule, calendar: calendar),
           statusByDay[today] == true {
            cursor = today
        } else {
            cursor = scheduleResolver.previousScheduledDate(before: today, schedule: schedule, calendar: calendar)
        }

        var streak = 0
        while let day = cursor, statusByDay[day] == true {
            streak += 1
            cursor = scheduleResolver.previousScheduledDate(before: day, schedule: schedule, calendar: calendar)
        }

        return streak
    }

    public func bestStreak(
        completions: [HabitCompletionSnapshot],
        schedule: HabitScheduleSnapshot,
        asOf date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> Int {
        let statusByDay = keepAliveStatusByDay(completions: completions, calendar: calendar)
        guard let firstDate = completions.map({ calendar.startOfDay(for: $0.date) }).min() else {
            return 0
        }

        let scheduledDays = scheduleResolver.scheduledDates(
            from: firstDate,
            through: date,
            schedule: schedule,
            calendar: calendar
        )

        var best = 0
        var current = 0

        for day in scheduledDays {
            if statusByDay[day] == true {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    private func keepAliveStatusByDay(completions: [HabitCompletionSnapshot], calendar: Calendar) -> [Date: Bool] {
        completions.reduce(into: [:]) { result, completion in
            let day = calendar.startOfDay(for: completion.date)
            result[day] = (result[day] ?? false) || completion.status.keepsHabitAlive
        }
    }
}
