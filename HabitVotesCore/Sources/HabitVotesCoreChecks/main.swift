import Foundation
import HabitVotesCore

enum CheckFailure: Error, CustomStringConvertible {
    case failed(String)

    var description: String {
        switch self {
        case .failed(let message):
            message
        }
    }
}

func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else { throw CheckFailure.failed(message) }
}

var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(secondsFromGMT: 0)!
calendar.firstWeekday = 2
calendar.locale = Locale(identifier: "en_US_POSIX")

func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
}

let streak = StreakCalculator().currentStreak(
    completions: [
        HabitCompletionSnapshot(date: date(2026, 6, 6), status: .completed),
        HabitCompletionSnapshot(date: date(2026, 6, 7), status: .miniCompleted),
        HabitCompletionSnapshot(date: date(2026, 6, 8), status: .completed)
    ],
    schedule: .daily,
    asOf: date(2026, 6, 9),
    calendar: calendar
)

let recovery = RecoveryModeResolver().state(
    completions: [HabitCompletionSnapshot(date: date(2026, 6, 6), status: .completed)],
    schedule: .daily,
    asOf: date(2026, 6, 9),
    calendar: calendar
)

let rate = HabitProgressCalculator().weeklyCompletionRate(
    completions: [
        HabitCompletionSnapshot(date: date(2026, 6, 8), status: .completed),
        HabitCompletionSnapshot(date: date(2026, 6, 9), status: .miniCompleted)
    ],
    schedule: HabitScheduleSnapshot(cadence: .selectedWeekdays, selectedWeekdays: [2, 3, 4, 5, 6]),
    weekContaining: date(2026, 6, 9),
    calendar: calendar
)

do {
    try expect(streak == 3, "2-minute completions should keep a 3-day streak alive")
    if case .emphasized(let missedDate) = recovery {
        try expect(calendar.isDate(missedDate, inSameDayAs: date(2026, 6, 8)), "Recovery should point at the previous missed day")
    } else {
        throw CheckFailure.failed("Expected emphasized recovery after two missed days")
    }
    try expect(abs(rate - 0.4) < 0.001, "Weekly rate should count two keep-alive completions across five scheduled days")
    print("HabitVotesCore checks passed")
} catch {
    fputs("HabitVotesCore checks failed: \(error)\n", stderr)
    exit(1)
}
