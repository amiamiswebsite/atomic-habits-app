import SwiftUI

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 64, height: 64)
                .background(AppTheme.accent.opacity(0.12), in: Circle())

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.xl)
        .accessibilityElement(children: .combine)
    }
}

struct RecoveryPromptCard: View {
    var twoMinuteVersion: String
    var emphasized: Bool
    var action: () -> Void

    var body: some View {
        GlassHabitCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                IdentityVoteBadge(text: emphasized ? "Recovery focus" : "Gentle reset", systemImage: "arrow.counterclockwise.circle.fill")
                Text("Today is about getting back on track.")
                    .font(.headline.weight(.semibold))
                Text(twoMinuteVersion)
                    .font(.body)
                    .foregroundStyle(.secondary)
                SecondaryButton(title: "Do the 2-minute version", systemImage: "timer") {
                    action()
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

struct NotificationPermissionPrompt: View {
    var requestPermission: () -> Void
    var skip: () -> Void

    var body: some View {
        GlassHabitCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Label("Reminder", systemImage: "bell.badge")
                    .font(.headline.weight(.semibold))
                Text("A quiet cue can help the habit meet you at the right moment.")
                    .foregroundStyle(.secondary)
                HStack {
                    SecondaryButton(title: "Not now", systemImage: nil, action: skip)
                    SecondaryButton(title: "Allow reminders", systemImage: "bell", action: requestPermission)
                }
            }
        }
    }
}
