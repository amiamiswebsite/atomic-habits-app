import Foundation

public enum HabitCompletionStatus: String, Codable, CaseIterable, Sendable, Hashable {
    case completed
    case miniCompleted
    case skipped
    case missed
    case recovered

    public var keepsHabitAlive: Bool {
        switch self {
        case .completed, .miniCompleted, .recovered:
            true
        case .skipped, .missed:
            false
        }
    }

    public var identityVoteValue: Int {
        keepsHabitAlive ? 1 : 0
    }

    public var displayName: String {
        switch self {
        case .completed:
            "Done"
        case .miniCompleted:
            "2-minute version"
        case .skipped:
            "Skipped"
        case .missed:
            "Missed"
        case .recovered:
            "Recovered"
        }
    }
}

public struct HabitCompletionSnapshot: Hashable, Sendable {
    public var date: Date
    public var status: HabitCompletionStatus
    public var completedAt: Date?

    public init(date: Date, status: HabitCompletionStatus, completedAt: Date? = nil) {
        self.date = date
        self.status = status
        self.completedAt = completedAt
    }
}
