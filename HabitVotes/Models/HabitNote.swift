import Foundation
import SwiftData

@Model
final class HabitNote {
    @Attribute(.unique) var id: UUID
    var habitId: UUID
    var body: String
    var createdAt: Date
    var habit: Habit?

    init(id: UUID = UUID(), habitId: UUID, body: String, createdAt: Date = Date()) {
        self.id = id
        self.habitId = habitId
        self.body = body
        self.createdAt = createdAt
    }
}
