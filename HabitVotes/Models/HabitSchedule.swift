import Foundation
import HabitVotesCore
import SwiftData

@Model
final class HabitSchedule {
    @Attribute(.unique) var id: UUID
    private var cadenceRaw: String
    private var selectedWeekdaysRaw: String

    init(
        id: UUID = UUID(),
        cadence: HabitCadence = .daily,
        selectedWeekdays: Set<Int> = []
    ) {
        self.id = id
        self.cadenceRaw = cadence.rawValue
        self.selectedWeekdaysRaw = selectedWeekdays.sorted().map(String.init).joined(separator: ",")
    }

    var cadence: HabitCadence {
        get { HabitCadence(rawValue: cadenceRaw) ?? .daily }
        set { cadenceRaw = newValue.rawValue }
    }

    var selectedWeekdays: Set<Int> {
        get {
            Set(selectedWeekdaysRaw.split(separator: ",").compactMap { Int($0) })
        }
        set {
            selectedWeekdaysRaw = newValue.sorted().map(String.init).joined(separator: ",")
        }
    }

    var snapshot: HabitScheduleSnapshot {
        HabitScheduleSnapshot(cadence: cadence, selectedWeekdays: selectedWeekdays)
    }
}
