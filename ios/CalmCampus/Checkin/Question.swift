import Foundation

/// One check-in question. Questions are data: the wording lives in `QuestionBank`,
/// the rules for when to ask them live in `CheckinPlanner`.
///
/// `id` is stable forever; bump `version` whenever the wording or the options
/// change, so stored answers from different wordings are never mixed up.
struct Question: Identifiable, Equatable {
    enum Tier: Equatable {
        /// Asked every day, with identical wording, so answers stay comparable.
        case core
        /// Asked only when a rule fires (missing data, a deviation, a high score).
        case targeted
        /// Low-frequency context questions; at most one per day, least recently asked first.
        case rotating
    }

    let id: String
    let version: Int
    let prompt: String
    let kind: ResponseKind
    let tier: Tier
    /// Minimum days between two askings (0 = may be asked every day).
    let cooldownDays: Int
}

enum ResponseKind: Equatable {
    case scale(ScaleSpec)
    case choice(options: [ChoiceOption], multiple: Bool)
    case hours(range: ClosedRange<Double>, step: Double, initial: Double)
}

struct ScaleSpec: Equatable {
    let range: ClosedRange<Int>
    let lowLabel: String
    let highLabel: String
}

struct ChoiceOption: Identifiable, Equatable {
    let id: String
    let label: String
}

enum Answer: Equatable {
    case scale(Int)
    case choices(Set<String>)
    case hours(Double)
    case skipped

    var scaleValue: Int? {
        if case .scale(let v) = self { return v }
        return nil
    }
}

/// A question the planner decided to ask, plus why — shown in the UI and stored
/// with the answer, so "You slept 1.5 h less than usual" can be audited later.
struct PlannedQuestion: Equatable {
    let question: Question
    let reason: String?
}
