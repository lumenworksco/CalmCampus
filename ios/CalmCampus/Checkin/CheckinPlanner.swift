import Foundation

/// Decides which questions to ask today. Pure: same context + answers → same plan.
///
/// The plan is recomputed after every answer, so follow-ups appear only when
/// earlier answers call for them (e.g. high stress → "what's weighing on you?").
///
/// Burden budget: 3 core questions, the sleep fallback when Health has no sleep,
/// and at most `maxExtra` targeted/rotating questions.
enum CheckinPlanner {
    static let maxExtra = 2
    /// Sleep this much below the usual amount counts as a short night.
    static let shortSleepThreshold = 1.25
    /// Yesterday's steps below this fraction of usual counts as a quiet day.
    static let lowActivityFraction = 0.5
    static let highStress = 4

    static func plan(context: CheckinContext, answers: [String: Answer],
                     calendar: Calendar = .current) -> [PlannedQuestion] {
        var plan = QuestionBank.core.map { PlannedQuestion(question: $0, reason: nil) }

        if context.lastNightSleepHours == nil {
            plan.append(PlannedQuestion(question: QuestionBank.sleepHours,
                                        reason: "No sleep data from Apple Health for last night."))
        }

        var extras: [PlannedQuestion] = []

        if let stress = answers[QuestionBank.stress.id]?.scaleValue, stress >= highStress {
            extras.append(PlannedQuestion(question: QuestionBank.stressors,
                                          reason: "You said today feels stressful."))
        }

        if let slept = context.lastNightSleepHours, let usual = context.sleepBaselineHours,
           usual - slept >= shortSleepThreshold,
           isOffCooldown(QuestionBank.sleepDisruption, context, calendar) {
            extras.append(PlannedQuestion(
                question: QuestionBank.sleepDisruption,
                reason: "You slept about \(hours(usual - slept)) less than your usual \(hours(usual))."))
        }

        if let steps = context.yesterdaySteps, let usual = context.stepsBaseline, usual > 0,
           Double(steps) < Double(usual) * lowActivityFraction,
           isOffCooldown(QuestionBank.lowActivity, context, calendar) {
            extras.append(PlannedQuestion(
                question: QuestionBank.lowActivity,
                reason: "Yesterday was quieter than usual: about \(thousands(steps)) steps, usually around \(thousands(usual))."))
        }

        // One rotating question per day: never-asked first, then least recently asked.
        let dueRotating = QuestionBank.rotating
            .filter { isOffCooldown($0, context, calendar) }
            .min { (context.lastAsked[$0.id] ?? .distantPast) < (context.lastAsked[$1.id] ?? .distantPast) }
        if let rotating = dueRotating {
            extras.append(PlannedQuestion(question: rotating, reason: nil))
        }

        return plan + extras.prefix(maxExtra)
    }

    /// The next unanswered question, or nil when the check-in is complete.
    static func next(context: CheckinContext, answers: [String: Answer]) -> PlannedQuestion? {
        plan(context: context, answers: answers).first { answers[$0.question.id] == nil }
    }

    /// Whether the answers suggest offering support resources after the check-in.
    /// Not a diagnosis — just a gentle "here's who you can talk to".
    static func shouldOfferSupport(_ answers: [String: Answer]) -> Bool {
        let mood = answers[QuestionBank.mood.id]?.scaleValue
        let stress = answers[QuestionBank.stress.id]?.scaleValue
        return (mood.map { $0 <= 2 } ?? false) || stress == 5
    }

    private static func isOffCooldown(_ q: Question, _ context: CheckinContext, _ calendar: Calendar) -> Bool {
        guard let last = context.lastAsked[q.id] else { return true }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: last), to: context.today).day ?? 0
        return days >= max(q.cooldownDays, 1)
    }

    private static func hours(_ h: Double) -> String {
        let rounded = (h * 2).rounded() / 2
        return rounded.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(rounded)) h" : String(format: "%.1f h", rounded)
    }

    private static func thousands(_ n: Int) -> String {
        n.formatted(.number.rounded(increment: 100))
    }
}
