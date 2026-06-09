import Foundation
import HabitVotesCore
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var title: String
    var identityStatement: String
    var twoMinuteVersion: String
    private var cueTypeRaw: String
    var cueDescription: String
    private var rewardStyleRaw: String
    var createdAt: Date
    var archivedAt: Date?
    var sortOrder: Int

    @Relationship(deleteRule: .cascade) var schedule: HabitSchedule?
    @Relationship(deleteRule: .cascade) var reminder: HabitReminder?
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit) var completions: [HabitCompletion] = []
    @Relationship(deleteRule: .cascade, inverse: \HabitNote.habit) var notes: [HabitNote] = []

    init(
        id: UUID = UUID(),
        title: String,
        identityStatement: String,
        twoMinuteVersion: String,
        cueType: HabitCueType = .afterEvent,
        cueDescription: String,
        schedule: HabitSchedule = HabitSchedule(),
        reminder: HabitReminder? = nil,
        rewardStyle: RewardStyle = .quiet,
        createdAt: Date = Date(),
        archivedAt: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.identityStatement = identityStatement
        self.twoMinuteVersion = twoMinuteVersion
        self.cueTypeRaw = cueType.rawValue
        self.cueDescription = cueDescription
        self.schedule = schedule
        self.reminder = reminder
        self.rewardStyleRaw = rewardStyle.rawValue
        self.createdAt = createdAt
        self.archivedAt = archivedAt
        self.sortOrder = sortOrder
    }

    var cueType: HabitCueType {
        get { HabitCueType(rawValue: cueTypeRaw) ?? .custom }
        set { cueTypeRaw = newValue.rawValue }
    }

    var rewardStyle: RewardStyle {
        get { RewardStyle(rawValue: rewardStyleRaw) ?? .quiet }
        set { rewardStyleRaw = newValue.rawValue }
    }

    var isArchived: Bool {
        archivedAt != nil
    }

    var scheduleSnapshot: HabitScheduleSnapshot {
        schedule?.snapshot ?? .daily
    }

    var completionSnapshots: [HabitCompletionSnapshot] {
        completions.map {
            HabitCompletionSnapshot(date: $0.date, status: $0.status, completedAt: $0.completedAt)
        }
    }

    func isCompleted(on date: Date, calendar: Calendar = .habitVotesGregorian) -> Bool {
        completions.contains {
            calendar.isDate($0.date, inSameDayAs: date) && $0.status.keepsHabitAlive
        }
    }
}
