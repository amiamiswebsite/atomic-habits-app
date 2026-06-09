import Charts
import SwiftUI

struct WeeklyProgressChart: View {
    var days: [DayProgress]

    var body: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Progress", day.rate)
            )
            .foregroundStyle(AppTheme.accent.gradient)
            .cornerRadius(5)
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 0.5, 1]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(doubleValue, format: .percent.precision(.fractionLength(0)))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.narrow))
            }
        }
        .frame(height: 180)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weekly completion chart")
        .accessibilityValue(accessibleSummary)
    }

    private var accessibleSummary: String {
        let completed = days.reduce(0) { $0 + $1.completed }
        let scheduled = days.reduce(0) { $0 + $1.scheduled }
        return "\(completed) of \(scheduled) scheduled habit votes completed"
    }
}

struct HabitHeatmap: View {
    var completions: [HabitCompletionSnapshot]
    var date: Date = Date()
    var calendar: Calendar = .habitVotesGregorian

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(days, id: \.self) { day in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color(for: day))
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel(day.formatted(date: .abbreviated, time: .omitted))
                    .accessibilityValue(value(for: day))
            }
        }
    }

    private var days: [Date] {
        let end = calendar.startOfDay(for: date)
        return (0..<35).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 34, to: end)
        }
    }

    private func status(for day: Date) -> HabitCompletionStatus? {
        completions.first {
            calendar.isDate($0.date, inSameDayAs: day) && $0.status.keepsHabitAlive
        }?.status
    }

    private func color(for day: Date) -> Color {
        switch status(for: day) {
        case .completed:
            AppTheme.accent
        case .miniCompleted:
            AppTheme.accent.opacity(0.62)
        case .recovered:
            AppTheme.recovery
        default:
            Color.secondary.opacity(0.16)
        }
    }

    private func value(for day: Date) -> String {
        status(for: day)?.displayName ?? "No vote"
    }
}
