import SwiftUI

struct GlassHabitCard<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(DesignTokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                    .strokeBorder(.separator.opacity(0.3), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }
}

struct IdentityVoteBadge: View {
    var text: String
    var systemImage: String = "checkmark.seal.fill"

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.accent)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(AppTheme.accent.opacity(0.12), in: Capsule())
            .accessibilityElement(children: .combine)
    }
}
