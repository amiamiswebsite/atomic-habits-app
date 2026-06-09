import XCTest
import HabitVotesCore

final class HabitVotesCoreBridgeTests: XCTestCase {
    func testMiniCompletionCountsAsIdentityVote() {
        XCTAssertTrue(HabitCompletionStatus.miniCompleted.keepsHabitAlive)
        XCTAssertEqual(HabitCompletionStatus.miniCompleted.identityVoteValue, 1)
    }

    func testReminderBodyIncludesCueAndAction() {
        let descriptors = ReminderScheduler().descriptors(
            habitID: UUID(uuidString: "00000000-0000-0000-0000-000000000042")!,
            title: "Walk",
            cueDescription: "After lunch",
            twoMinuteVersion: "walk for 2 minutes",
            schedule: .daily,
            reminderMinutesFromMidnight: [12 * 60 + 30]
        )

        XCTAssertEqual(descriptors.first?.body, "After lunch: walk for 2 minutes")
    }
}
