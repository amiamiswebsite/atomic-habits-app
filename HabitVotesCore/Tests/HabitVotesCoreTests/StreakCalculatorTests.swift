import XCTest
@testable import HabitVotesCore

final class StreakCalculatorTests: XCTestCase {
    private var calendar: Calendar!
    private let calculator = StreakCalculator()

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        self.calendar = calendar
    }

    func testTwoMinuteCompletionKeepsStreakAlive() {
        let streak = calculator.currentStreak(
            completions: [
                completion(2026, 6, 6, .completed),
                completion(2026, 6, 7, .miniCompleted),
                completion(2026, 6, 8, .completed)
            ],
            schedule: .daily,
            asOf: date(2026, 6, 9),
            calendar: calendar
        )

        XCTAssertEqual(streak, 3)
    }

    func testSkippedDayBreaksBestStreak() {
        let best = calculator.bestStreak(
            completions: [
                completion(2026, 6, 4, .completed),
                completion(2026, 6, 5, .completed),
                completion(2026, 6, 6, .skipped),
                completion(2026, 6, 7, .completed),
                completion(2026, 6, 8, .completed)
            ],
            schedule: .daily,
            asOf: date(2026, 6, 9),
            calendar: calendar
        )

        XCTAssertEqual(best, 2)
    }

    func testSelectedWeekdaysIgnoreOffDays() {
        let schedule = HabitScheduleSnapshot(cadence: .selectedWeekdays, selectedWeekdays: [2, 4])
        let streak = calculator.currentStreak(
            completions: [
                completion(2026, 6, 1, .completed),
                completion(2026, 6, 3, .miniCompleted),
                completion(2026, 6, 8, .completed)
            ],
            schedule: schedule,
            asOf: date(2026, 6, 10),
            calendar: calendar
        )

        XCTAssertEqual(streak, 3)
    }

    private func completion(_ year: Int, _ month: Int, _ day: Int, _ status: HabitCompletionStatus) -> HabitCompletionSnapshot {
        HabitCompletionSnapshot(date: date(year, month, day), status: status, completedAt: date(year, month, day, 8))
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }
}
