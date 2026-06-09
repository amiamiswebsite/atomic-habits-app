import Foundation
import HabitVotesCore
import UserNotifications

@MainActor
struct LocalReminderService {
    private let center: UNUserNotificationCenter
    private let scheduler = ReminderScheduler()

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for habit: Habit) async throws {
        guard let reminder = habit.reminder, reminder.isEnabled else {
            await removeReminders(for: habit.id)
            return
        }

        let descriptors = scheduler.descriptors(
            habitID: habit.id,
            title: habit.title,
            cueDescription: habit.cueDescription,
            twoMinuteVersion: habit.twoMinuteVersion,
            schedule: habit.scheduleSnapshot,
            reminderMinutesFromMidnight: reminder.reminderMinutes
        )

        await removeReminders(for: habit.id)

        for descriptor in descriptors {
            let content = UNMutableNotificationContent()
            content.title = descriptor.title
            content.body = descriptor.body.isEmpty ? "Tiny action now. Future you gets the vote." : descriptor.body
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.weekday = descriptor.weekday
            dateComponents.hour = descriptor.hour
            dateComponents.minute = descriptor.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: descriptor.identifier, content: content, trigger: trigger)
            try await center.add(request)
        }
    }

    func removeReminders(for habitID: UUID) async {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.contains(habitID.uuidString) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
