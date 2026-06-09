import Foundation

public enum HabitCadence: String, Codable, CaseIterable, Sendable, Hashable {
    case daily
    case selectedWeekdays
}

public struct HabitScheduleSnapshot: Hashable, Sendable {
    public var cadence: HabitCadence
    public var selectedWeekdays: Set<Int>

    public init(cadence: HabitCadence = .daily, selectedWeekdays: Set<Int> = []) {
        self.cadence = cadence
        self.selectedWeekdays = selectedWeekdays
    }

    public static let daily = HabitScheduleSnapshot(cadence: .daily)
}

public extension Calendar {
    static var habitVotesGregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .current
        return calendar
    }
}
