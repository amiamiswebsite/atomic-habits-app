import XCTest
@testable import HabitVotesCore

final class ScheduleAndRecoveryTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        self.calendar = calendar
    }

    func testScheduleResolverHandlesSelectedWeekdays() {
        let days = ScheduleResolver().scheduledDates(
            from: date(2026, 6, 1),
            through: date(2026, 6, 7),
            schedule: HabitScheduleSnapshot(cadence: .selectedWeekdays, selectedWeekdays: [2, 4]),
            calendar: calendar
        )

        XCTAssertEqual(days, [date(2026, 6, 1), date(2026, 6, 3)])
    }

    func testRecoveryIsGentleAfterOneMissedScheduledDay() {
        let state = RecoveryModeResolver().state(
            completions: [completion(2026, 6, 7, .completed)],
            schedule: .daily,
            asOf: date(2026, 6, 9),
            calendar: calendar
        )

        if case .gentle(let missedDate) = state {
            XCTAssertEqual(missedDate, date(2026, 6, 8))
        } else {
            XCTFail("Expected gentle recovery")
        }
    }

    func testRecoveryIsEmphasizedAfterTwoMissedScheduledDays() {
        let state = RecoveryModeResolver().state(
            completions: [completion(2026, 6, 6, .completed)],
            schedule: .daily,
            asOf: date(2026, 6, 9),
            calendar: calendar
        )

        if case .emphasized(let missedDate) = state {
            XCTAssertEqual(missedDate, date(2026, 6, 8))
        } else {
            XCTFail("Expected emphasized recovery")
        }
    }

    private func completion(_ year: Int, _ month: Int, _ day: Int, _ status: HabitCompletionStatus) -> HabitCompletionSnapshot {
        HabitCompletionSnapshot(date: date(year, month, day), status: status)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }
}
