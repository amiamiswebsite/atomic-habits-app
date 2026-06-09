import SwiftUI

struct HabitProgressRing: View {
    var progress: Double
    var completed: Int
    var total: Int
    var lineWidth: CGFloat = 14

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AppTheme.accent.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeOut(duration: 0.55), value: progress)

            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text("\(completed)")
                    .font(.title.bold())
                    .contentTransition(.numericText())
                Text("of \(max(total, 0))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today progress")
        .accessibilityValue("\(completed) of \(total) habits complete")
    }
}
