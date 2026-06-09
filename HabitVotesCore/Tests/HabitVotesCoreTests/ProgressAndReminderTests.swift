import XCTest
@testable import HabitVotesCore

final class ProgressAndReminderTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "en_US_POSIX")
        self.calendar = calendar
    }

    func testWeeklyCompletionRateCountsMiniCompletion() {
        let rate = HabitProgressCalculator().weeklyCompletionRate(
            completions: [
                HabitCompletionSnapshot(date: date(2026, 6, 8), status: .completed),
                HabitCompletionSnapshot(date: date(2026, 6, 9), status: .miniCompleted)
            ],
            schedule: HabitScheduleSnapshot(cadence: .selectedWeekdays, selectedWeekdays: [2, 3, 4, 5, 6]),
            weekContaining: date(2026, 6, 9),
            calendar: calendar
        )

        XCTAssertEqual(rate, 0.4, accuracy: 0.001)
    }

    func testReminderDescriptorsUseCueAndSmallAction() {
        let habitID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let descriptors = ReminderScheduler().descriptors(
            habitID: habitID,
            title: "Read",
            cueDescription: "After coffee",
            twoMinuteVersion: "read one page",
            schedule: HabitScheduleSnapshot(cadence: .selectedWeekdays, selectedWeekdays: [2, 4]),
            reminderMinutesFromMidnight: [8 * 60 + 15]
        )

        XCTAssertEqual(descriptors.count, 2)
        XCTAssertEqual(descriptors[0].body, "After coffee: read one page")
        XCTAssertEqual(descriptors[0].weekday, 2)
        XCTAssertEqual(descriptors[0].hour, 8)
        XCTAssertEqual(descriptors[0].minute, 15)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month, day: day, hour: hour).date!
    }
}
