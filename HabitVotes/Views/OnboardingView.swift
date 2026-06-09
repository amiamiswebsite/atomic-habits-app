import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var step = 0
    @State private var identity = "I am someone who keeps learning."
    @State private var title = "Read one page"
    @State private var twoMinuteVersion = "Read one paragraph"
    @State private var cueDescription = "After coffee"
    @State private var wantsReminder = false
    @State private var reminderDate = Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: .now) ?? .now
    @State private var rewardStyle: RewardStyle = .quiet
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var canContinue: Bool {
        switch step {
        case 1:
            !identity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2:
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3:
            !twoMinuteVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 4:
            !cueDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step + 1), total: 8)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.md)

                TabView(selection: $step) {
                    welcome.tag(0)
                    identityStep.tag(1)
                    actionStep.tag(2)
                    miniStep.tag(3)
                    cueStep.tag(4)
                    reminderStep.tag(5)
                    rewardStep.tag(6)
                    summaryStep.tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .smooth(duration: 0.28), value: step)
                .accessibilityElement(children: .contain)

                VStack(spacing: DesignTokens.Spacing.sm) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PrimaryCTAButton(
                        title: step == 7 ? "Create habit" : "Continue",
                        systemImage: step == 7 ? "checkmark" : "arrow.right",
                        isLoading: isSaving,
                        isDisabled: !canContinue,
                        action: continueTapped
                    )

                    if step > 0 {
                        SecondaryButton(title: "Back", systemImage: "arrow.left") {
                            step = max(0, step - 1)
                        }
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
        }
    }

    private var welcome: some View {
        OnboardingStepView(
            title: "Every small action becomes visible proof.",
            subtitle: "Create one calm habit vote. Keep it tiny enough to do on real days.",
            systemImage: "sparkle.magnifyingglass"
        )
    }

    private var identityStep: some View {
        OnboardingStepView(title: "Who are you becoming?", subtitle: "Use words you would be proud to repeat.", systemImage: "person.crop.circle.badge.checkmark") {
            TextField("I am someone who...", text: $identity, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }

    private var actionStep: some View {
        OnboardingStepView(title: "What small action proves this?", subtitle: "Keep it specific and visible.", systemImage: "checkmark.circle") {
            TextField("Read one page", text: $title)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var miniStep: some View {
        OnboardingStepView(title: "What is the 2-minute version?", subtitle: "This keeps the habit alive when the day gets tight.", systemImage: "timer") {
            TextField("Read one paragraph", text: $twoMinuteVersion)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var cueStep: some View {
        OnboardingStepView(title: "When will it happen?", subtitle: "Anchor it after something already familiar.", systemImage: "link") {
            TextField("After coffee", text: $cueDescription)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var reminderStep: some View {
        OnboardingStepView(title: "Do you want a reminder?", subtitle: "Permission is requested only after the habit exists.", systemImage: "bell") {
            Toggle("Use a quiet reminder", isOn: $wantsReminder)
                .toggleStyle(.switch)
            if wantsReminder {
                DatePicker("Reminder time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
            }
        }
    }

    private var rewardStep: some View {
        OnboardingStepView(title: "How should the win feel?", subtitle: "Choose the tone of your completion moment.", systemImage: "seal") {
            Picker("Reward tone", selection: $rewardStyle) {
                ForEach(RewardStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var summaryStep: some View {
        OnboardingStepView(title: "Your first habit vote", subtitle: "Simple enough to begin today.", systemImage: "checkmark.seal") {
            GlassHabitCard {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    IdentityVoteBadge(text: rewardStyle.completionPhrase)
                    Text(title).font(.title3.weight(.semibold))
                    Text(identity).foregroundStyle(.secondary)
                    Label(cueDescription, systemImage: "link")
                    Label(twoMinuteVersion, systemImage: "timer")
                }
            }
        }
    }

    private func continueTapped() {
        guard step == 7 else {
            step += 1
            return
        }

        Task { await createHabit() }
    }

    @MainActor
    private func createHabit() async {
        isSaving = true
        errorMessage = nil
        let reminder = HabitReminder(isEnabled: wantsReminder)
        reminder.firstReminderDate = reminderDate
        let habit = Habit(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            identityStatement: identity.trimmingCharacters(in: .whitespacesAndNewlines),
            twoMinuteVersion: twoMinuteVersion.trimmingCharacters(in: .whitespacesAndNewlines),
            cueDescription: cueDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            schedule: HabitSchedule(cadence: .daily),
            reminder: reminder,
            rewardStyle: rewardStyle
        )
        modelContext.insert(habit)

        do {
            try modelContext.save()
            WidgetSnapshotWriter.write(habits: [habit])
            if wantsReminder {
                let service = LocalReminderService()
                if try await service.requestAuthorization() {
                    try await service.scheduleReminder(for: habit)
                }
            }
            AppHaptics.completion()
        } catch {
            errorMessage = "The habit could not be saved. Please try again."
        }
        isSaving = false
    }
}

struct OnboardingStepView<Content: View>: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var content: Content

    init(title: String, subtitle: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                Image(systemName: systemImage)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 76, height: 76)
                    .background(AppTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.lg)
        }
    }
}

extension OnboardingStepView where Content == EmptyView {
    init(title: String, subtitle: String, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = EmptyView()
    }
}
