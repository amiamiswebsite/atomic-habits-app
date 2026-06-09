import SwiftUI

struct PrimaryCTAButton: View {
    var title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    var action: () -> Void

    var body: some View {
        Button {
            guard !isLoading, !isDisabled else { return }
            AppHaptics.selection()
            action()
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .fill(isDisabled ? Color.secondary.opacity(0.35) : AppTheme.accent)
        )
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .opacity(isLoading ? 0.82 : 1)
        .disabled(isDisabled || isLoading)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
    }
}

struct SecondaryButton: View {
    var title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button {
            AppHaptics.selection()
            action()
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                    .strokeBorder(.separator.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppTheme.primaryText)
        .accessibilityLabel(title)
    }
}
