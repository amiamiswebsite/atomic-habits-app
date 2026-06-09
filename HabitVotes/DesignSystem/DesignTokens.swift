import SwiftUI

enum DesignTokens {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 44
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let full: CGFloat = 999
    }

    enum Motion {
        static let quick: Duration = .milliseconds(180)
        static let standard: Duration = .milliseconds(320)
        static let completion: Duration = .milliseconds(620)
    }
}

enum AppTheme {
    static let accent = Color.accentColor
    static let success = Color.green
    static let recovery = Color.orange
    static let quietSurface = Color(.secondarySystemGroupedBackground)
    static let pageBackground = Color(.systemGroupedBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary

    static var cardMaterial: Material { .regularMaterial }
    static var elevatedMaterial: Material { .ultraThinMaterial }
}

enum AppTypography {
    static func hero(_ text: LocalizedStringKey) -> Text {
        Text(text).font(.largeTitle.weight(.bold))
    }

    static func section(_ text: LocalizedStringKey) -> Text {
        Text(text).font(.title3.weight(.semibold))
    }

    static func cardTitle(_ text: String) -> Text {
        Text(text).font(.headline.weight(.semibold))
    }

    static func caption(_ text: String) -> Text {
        Text(text).font(.caption.weight(.medium))
    }
}
