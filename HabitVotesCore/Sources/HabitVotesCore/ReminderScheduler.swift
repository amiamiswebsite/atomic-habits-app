import Foundation

public struct ReminderRequestDescriptor: Equatable, Sendable {
    public var identifier: String
    public var title: String
    public var body: String
    public var weekday: Int?
    public var hour: Int
    public var minute: Int

    public init(identifier: String, title: String, body: String, weekday: Int?, hour: Int, minute: Int) {
        self.identifier = identifier
        self.title = title
        self.body = body
        self.weekday = weekday
        self.hour = hour
        self.minute = minute
    }
}

public struct ReminderScheduler: Sendable {
    public init() {}

    public func descriptors(
        habitID: UUID,
        title: String,
        cueDescription: String,
        twoMinuteVersion: String,
        schedule: HabitScheduleSnapshot,
        reminderMinutesFromMidnight: [Int]
    ) -> [ReminderRequestDescriptor] {
        let weekdays: [Int?]
        switch schedule.cadence {
        case .daily:
            weekdays = [nil]
        case .selectedWeekdays:
            weekdays = schedule.selectedWeekdays.sorted().map(Optional.some)
        }

        return weekdays.flatMap { weekday in
            reminderMinutesFromMidnight.sorted().map { minutes in
                let hour = max(0, min(23, minutes / 60))
                let minute = max(0, min(59, minutes % 60))
                let weekdaySuffix = weekday.map { ".weekday.\($0)" } ?? ".daily"
                return ReminderRequestDescriptor(
                    identifier: "habitvotes.\(habitID.uuidString)\(weekdaySuffix).\(hour).\(minute)",
                    title: title,
                    body: "\(cueDescription): \(twoMinuteVersion)",
                    weekday: weekday,
                    hour: hour,
                    minute: minute
                )
            }
        }
    }
}
