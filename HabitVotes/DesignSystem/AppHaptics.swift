import UIKit

enum AppHaptics {
    @MainActor
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @MainActor
    static func completion() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    @MainActor
    static func gentleWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
