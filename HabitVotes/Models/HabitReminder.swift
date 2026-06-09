import Foundation
import SwiftData

@Model
final class HabitReminder {
    @Attribute(.unique) var id: UUID
    var isEnabled: Bool
    private var minutesFromMidnightRaw: String

    init(
        id: UUID = UUID(),
        isEnabled: Bool = false,
        reminderMinutes: [Int] = [8 * 60]
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.minutesFromMidnightRaw = reminderMinutes.sorted().map(String.init).joined(separator: ",")
    }

    var reminderMinutes: [Int] {
        get { minutesFromMidnightRaw.split(separator: ",").compactMap { Int($0) } }
        set { minutesFromMidnightRaw = newValue.sorted().map(String.init).joined(separator: ",") }
    }

    var firstReminderDate: Date {
        get {
            let minutes = reminderMinutes.first ?? 8 * 60
            var components = DateComponents()
            components.hour = minutes / 60
            components.minute = minutes % 60
            return Calendar.current.nextDate(after: .now, matching: components, matchingPolicy: .nextTime) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderMinutes = [(components.hour ?? 8) * 60 + (components.minute ?? 0)]
        }
    }
}
