import HabitVotesCore
import SwiftData
import SwiftUI

enum HabitEditMode {
    case create
    case edit(Habit)
}

struct HabitEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var mode: HabitEditMode

    @State private var title = ""
    @State private var identityStatement = ""
    @State private var twoMinuteVersion = ""
    @State private var cueDescription = ""
    @State private var cadence: HabitCadence = .daily
    @State private var selectedWeekdays: Set<Int> = [2, 3, 4, 5, 6]
    @State private var wantsReminder = false
    @State private var reminderDate = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: .now) ?? .now
    @State private var rewardStyle: RewardStyle = .quiet
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var existingHabit: Habit? {
        if case .edit(let habit) = mode { return habit }
        return nil
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !identityStatement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !twoMinuteVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !cueDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Identity") {
                TextField("Habit name", text: $title)
                TextField("Identity statement", text: $identityStatement, axis: .vertical)
                    .lineLimit(2...4)
            }

            Section("Action") {
                TextField("2-minute version", text: $twoMinuteVersion)
                TextField("Cue", text: $cueDescription)
            }

            Section("Schedule") {
                Picker("Cadence", selection: $cadence) {
                    Text("Daily").tag(HabitCadence.daily)
                    Text("Weekdays").tag(HabitCadence.selectedWeekdays)
                }
                .pickerStyle(.segmented)

                if cadence == .selectedWeekdays {
                    WeekdayPicker(selectedWeekdays: $selectedWeekdays)
                }
            }

            Section("Reminder") {
                Toggle("Quiet reminder", isOn: $wantsReminder)
                if wantsReminder {
                    DatePicker("Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                }
            }

            Section("Reward tone") {
                Picker("Reward tone", selection: $rewardStyle) {
                    ForEach(RewardStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(existingHabit == nil ? "New Habit" : "Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(!isValid || isSaving)
            }
        }
        .onAppear(perform: loadExistingHabit)
    }

    private func loadExistingHabit() {
        guard let habit = existingHabit else { return }
        title = habit.title
        identityStatement = habit.identityStatement
        twoMinuteVersion = habit.twoMinuteVersion
        cueDescription = habit.cueDescription
        cadence = habit.schedule?.cadence ?? .daily
        selectedWeekdays = habit.schedule?.selectedWeekdays ?? [2, 3, 4, 5, 6]
        wantsReminder = habit.reminder?.isEnabled ?? false
        reminderDate = habit.reminder?.firstReminderDate ?? reminderDate
        rewardStyle = habit.rewardStyle
    }

    @MainActor
    private func save() async {
        isSaving = true
        errorMessage = nil

        let target = existingHabit ?? Habit(
            title: title,
            identityStatement: identityStatement,
            twoMinuteVersion: twoMinuteVersion,
            cueDescription: cueDescription,
            sortOrder: Int(Date().timeIntervalSinceReferenceDate)
        )

        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.identityStatement = identityStatement.trimmingCharacters(in: .whitespacesAndNewlines)
        target.twoMinuteVersion = twoMinuteVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        target.cueDescription = cueDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        target.rewardStyle = rewardStyle

        let schedule = target.schedule ?? HabitSchedule()
        schedule.cadence = cadence
        schedule.selectedWeekdays = cadence == .selectedWeekdays ? selectedWeekdays : []
        target.schedule = schedule

        let reminder = target.reminder ?? HabitReminder()
        reminder.isEnabled = wantsReminder
        reminder.firstReminderDate = reminderDate
        target.reminder = reminder

        if existingHabit == nil {
            modelContext.insert(target)
        }

        do {
            try modelContext.save()
            if wantsReminder {
                let service = LocalReminderService()
                if try await service.requestAuthorization() {
                    try await service.scheduleReminder(for: target)
                }
            } else {
                await LocalReminderService().removeReminders(for: target.id)
            }
            WidgetSnapshotWriter.write(habits: [target])
            dismiss()
        } catch {
            errorMessage = "Could not save this habit."
        }

        isSaving = false
    }
}

struct WeekdayPicker: View {
    @Binding var selectedWeekdays: Set<Int>

    private struct WeekdayOption: Identifiable {
        var id: Int { weekday }
        var weekday: Int
        var label: String
    }

    private let weekdays: [WeekdayOption] = [
        WeekdayOption(weekday: 2, label: "M"),
        WeekdayOption(weekday: 3, label: "T"),
        WeekdayOption(weekday: 4, label: "W"),
        WeekdayOption(weekday: 5, label: "T"),
        WeekdayOption(weekday: 6, label: "F"),
        WeekdayOption(weekday: 7, label: "S"),
        WeekdayOption(weekday: 1, label: "S")
    ]

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(weekdays) { option in
                Button {
                    if selectedWeekdays.contains(option.weekday), selectedWeekdays.count > 1 {
                        selectedWeekdays.remove(option.weekday)
                    } else {
                        selectedWeekdays.insert(option.weekday)
                    }
                } label: {
                    Text(option.label)
                        .font(.caption.weight(.bold))
                        .frame(width: 34, height: 34)
                        .background(selectedWeekdays.contains(option.weekday) ? AppTheme.accent : Color.secondary.opacity(0.14), in: Circle())
                        .foregroundStyle(selectedWeekdays.contains(option.weekday) ? .white : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Weekday \(option.label)")
                .accessibilityValue(selectedWeekdays.contains(option.weekday) ? "Selected" : "Not selected")
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }
}
