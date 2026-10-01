import Foundation

/// All check-in wording in one place. DRAFT — to be reviewed by the team.
///
/// Rules for editing:
/// - Never change an `id`. Change wording or options → bump `version`.
/// - Core questions keep the exact same wording and labels every day.
/// - No clinical screeners (PHQ/GAD items, scores with cutoffs) and no
///   self-harm questions: this is a wellness app, not a diagnostic one (EU MDR).
enum QuestionBank {
    // MARK: Core — every day

    static let mood = Question(
        id: "mood", version: 1,
        prompt: "How are you feeling today?",
        kind: .scale(ScaleSpec(range: 1...5, lowLabel: "Very low", highLabel: "Very good")),
        tier: .core, cooldownDays: 0)

    static let energy = Question(
        id: "energy", version: 1,
        prompt: "How much energy do you have today?",
        kind: .scale(ScaleSpec(range: 1...5, lowLabel: "Running on empty", highLabel: "Full of energy")),
        tier: .core, cooldownDays: 0)

    static let stress = Question(
        id: "stress", version: 1,
        prompt: "How stressed do you feel today?",
        kind: .scale(ScaleSpec(range: 1...5, lowLabel: "Not at all", highLabel: "Extremely")),
        tier: .core, cooldownDays: 0)

    // MARK: Targeted — only when a rule fires

    /// Fallback when Apple Health has no sleep for last night (no wearable / no sleep schedule).
    static let sleepHours = Question(
        id: "sleep_hours", version: 1,
        prompt: "Roughly how many hours did you sleep last night?",
        kind: .hours(range: 0...14, step: 0.5, initial: 7),
        tier: .targeted, cooldownDays: 0)

    static let sleepDisruption = Question(
        id: "sleep_disruption", version: 1,
        prompt: "What got in the way of your sleep?",
        kind: .choice(options: [
            ChoiceOption(id: "studying", label: "Studying or a deadline"),
            ChoiceOption(id: "social", label: "Out late or social plans"),
            ChoiceOption(id: "screens", label: "Phone or screens"),
            ChoiceOption(id: "worries", label: "Worries or racing thoughts"),
            ChoiceOption(id: "environment", label: "Noise, roommates or the room"),
            ChoiceOption(id: "unwell", label: "Felt unwell"),
            ChoiceOption(id: "nothing", label: "Nothing in particular"),
        ], multiple: true),
        tier: .targeted, cooldownDays: 2)

    static let lowActivity = Question(
        id: "low_activity", version: 1,
        prompt: "What best describes yesterday?",
        kind: .choice(options: [
            ChoiceOption(id: "rest", label: "A rest day, by choice"),
            ChoiceOption(id: "studying", label: "Busy studying"),
            ChoiceOption(id: "unwell", label: "Felt unwell"),
            ChoiceOption(id: "motivation", label: "Low motivation"),
            ChoiceOption(id: "stuck_inside", label: "Weather or stuck inside"),
        ], multiple: false),
        tier: .targeted, cooldownDays: 3)

    static let stressors = Question(
        id: "stressors", version: 1,
        prompt: "What's weighing on you most?",
        kind: .choice(options: [
            ChoiceOption(id: "exams", label: "Exams or deadlines"),
            ChoiceOption(id: "workload", label: "Too much to do"),
            ChoiceOption(id: "money", label: "Money"),
            ChoiceOption(id: "relationships", label: "Family or relationships"),
            ChoiceOption(id: "lonely", label: "Feeling alone"),
            ChoiceOption(id: "health", label: "Health"),
            ChoiceOption(id: "future", label: "The future or career"),
            ChoiceOption(id: "other", label: "Something else"),
        ], multiple: true),
        tier: .targeted, cooldownDays: 0)

    // MARK: Rotating — weekly-ish context

    static let deadlineSoon = Question(
        id: "deadline_soon", version: 1,
        prompt: "Do you have an exam or a big deadline in the next 7 days?",
        kind: .choice(options: [
            ChoiceOption(id: "yes", label: "Yes"),
            ChoiceOption(id: "no", label: "No"),
        ], multiple: false),
        tier: .rotating, cooldownDays: 3)

    static let connection = Question(
        id: "connection", version: 1,
        prompt: "How connected have you felt to other people this week?",
        kind: .scale(ScaleSpec(range: 1...5, lowLabel: "Very alone", highLabel: "Very connected")),
        tier: .rotating, cooldownDays: 7)

    static let workloadControl = Question(
        id: "workload_control", version: 1,
        prompt: "How much in control of your workload do you feel this week?",
        kind: .scale(ScaleSpec(range: 1...5, lowLabel: "Not at all", highLabel: "Completely")),
        tier: .rotating, cooldownDays: 7)

    static let core = [mood, energy, stress]
    /// Order = priority when more than one is eligible on the same day.
    static let rotating = [deadlineSoon, connection, workloadControl]
}
