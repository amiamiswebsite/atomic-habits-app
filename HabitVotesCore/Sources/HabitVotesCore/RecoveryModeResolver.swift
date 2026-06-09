import Foundation

public enum RecoveryModeState: Equatable, Sendable {
    case none
    case gentle(previousMissedDate: Date)
    case emphasized(previousMissedDate: Date)
}

public struct RecoveryModeResolver: Sendable {
    private let scheduleResolver: ScheduleResolver

    public init(scheduleResolver: ScheduleResolver = ScheduleResolver()) {
        self.scheduleResolver = scheduleResolver
    }

    public func state(
        completions: [HabitCompletionSnapshot],
        schedule: HabitScheduleSnapshot,
        asOf date: Date = Date(),
        calendar: Calendar = .habitVotesGregorian
    ) -> RecoveryModeState {
        guard let previous = scheduleResolver.previousScheduledDate(before: date, schedule: schedule, calendar: calendar),
              missed(previous, completions: completions, calendar: calendar)
        else {
            return .none
        }

        if let secondPrevious = scheduleResolver.previousScheduledDate(before: previous, schedule: schedule, calendar: calendar),
           missed(secondPrevious, completions: completions, calendar: calendar) {
            return .emphasized(previousMissedDate: previous)
        }

        return .gentle(previousMissedDate: previous)
    }

    private func missed(_ day: Date, completions: [HabitCompletionSnapshot], calendar: Calendar) -> Bool {
        !completions.contains {
            calendar.isDate($0.date, inSameDayAs: day) && $0.status.keepsHabitAlive
        }
    }
}
