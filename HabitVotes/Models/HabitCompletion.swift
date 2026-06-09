import Foundation
import HabitVotesCore
import SwiftData

@Model
final class HabitCompletion {
    @Attribute(.unique) var id: UUID
    var habitId: UUID
    var date: Date
    private var statusRaw: String
    var note: String?
    var completedAt: Date
    var habit: Habit?

    init(
        id: UUID = UUID(),
        habitId: UUID,
        date: Date = Date(),
        status: HabitCompletionStatus = .completed,
        note: String? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.habitId = habitId
        self.date = date
        self.statusRaw = status.rawValue
        self.note = note
        self.completedAt = completedAt
    }

    var status: HabitCompletionStatus {
        get { HabitCompletionStatus(rawValue: statusRaw) ?? .completed }
        set { statusRaw = newValue.rawValue }
    }
}
