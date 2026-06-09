import Foundation

public struct ScheduleResolver: Sendable {
    public init() {}

    public func isScheduled(
        on date: Date,
        schedule: HabitScheduleSnapshot,
        calendar: Calendar = .habitVotesGregorian
    ) -> Bool {
        switch schedule.cadence {
        case .daily:
            true
        case .selectedWeekdays:
            schedule.selectedWeekdays.contains(calendar.component(.weekday, from: date))
        }
    }

    public func scheduledDates(
        from start: Date,
        through end: Date,
        schedule: HabitScheduleSnapshot,
        calendar: Calendar = .habitVotesGregorian
    ) -> [Date] {
        let lower = calendar.startOfDay(for: min(start, end))
        let upper = calendar.startOfDay(for: max(start, end))
        var dates: [Date] = []
        var cursor = lower

        while cursor <= upper {
            if isScheduled(on: cursor, schedule: schedule, calendar: calendar) {
                dates.append(cursor)
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        return dates
    }

    public func previousScheduledDate(
        before date: Date,
        schedule: HabitScheduleSnapshot,
        calendar: Calendar = .habitVotesGregorian
    ) -> Date? {
        var cursor = calendar.startOfDay(for: date)

        for _ in 0..<370 {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { return nil }
            if isScheduled(on: previous, schedule: schedule, calendar: calendar) {
                return previous
            }
            cursor = previous
        }

        return nil
    }

    public func nextScheduledDate(
        after date: Date,
        schedule: HabitScheduleSnapshot,
        calendar: Calendar = .habitVotesGregorian
    ) -> Date? {
        var cursor = calendar.startOfDay(for: date)

        for _ in 0..<370 {
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { return nil }
            if isScheduled(on: next, schedule: schedule, calendar: calendar) {
                return next
            }
            cursor = next
        }

        return nil
    }
}
