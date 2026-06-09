import Foundation

enum HabitCueType: String, Codable, CaseIterable, Identifiable {
    case afterEvent
    case timeOfDay
    case location
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .afterEvent:
            "After something"
        case .timeOfDay:
            "At a time"
        case .location:
            "At a place"
        case .custom:
            "Custom cue"
        }
    }
}

enum RewardStyle: String, Codable, CaseIterable, Identifiable {
    case quiet
    case proud
    case grounded
    case energized

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quiet:
            "Quiet"
        case .proud:
            "Proud"
        case .grounded:
            "Grounded"
        case .energized:
            "Energized"
        }
    }

    var completionPhrase: String {
        switch self {
        case .quiet:
            "Proof added."
        case .proud:
            "That counts."
        case .grounded:
            "Back to yourself."
        case .energized:
            "Momentum made."
        }
    }
}
