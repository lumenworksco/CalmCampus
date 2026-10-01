import Foundation
import SwiftData

/// One stored answer — a flat row per question per day.
///
/// "Answered" and "skipped" are both rows; "not asked" is the absence of a row.
/// Keeping those three apart matters for analysis: a skipped stress question is
/// not the same as a day we didn't ask.
@Model
final class CheckinResponse {
    enum Status: String, Codable { case answered, skipped }

    var day: Date
    var answeredAt: Date
    var questionID: String
    var questionVersion: Int
    var statusRaw: String
    var numericValue: Double?
    var choiceIDs: [String]
    /// Why the planner asked it (e.g. "You slept about 1.5 h less…"); nil for core questions.
    var triggerReason: String?

    init(day: Date, question: Question, answer: Answer, reason: String?, answeredAt: Date = .now) {
        self.day = day
        self.answeredAt = answeredAt
        self.questionID = question.id
        self.questionVersion = question.version
        self.triggerReason = reason
        switch answer {
        case .scale(let v):
            statusRaw = Status.answered.rawValue; numericValue = Double(v); choiceIDs = []
        case .hours(let h):
            statusRaw = Status.answered.rawValue; numericValue = h; choiceIDs = []
        case .choices(let ids):
            statusRaw = Status.answered.rawValue; numericValue = nil; choiceIDs = ids.sorted()
        case .skipped:
            statusRaw = Status.skipped.rawValue; numericValue = nil; choiceIDs = []
        }
    }

    var status: Status { Status(rawValue: statusRaw) ?? .skipped }
}

extension ModelContext {
    /// Replace today's check-in with a new set of answers (a redo overwrites, never duplicates).
    func saveCheckin(day: Date, planned: [PlannedQuestion], answers: [String: Answer]) throws {
        for old in try fetch(FetchDescriptor<CheckinResponse>(predicate: #Predicate { $0.day == day })) {
            delete(old)
        }
        for item in planned {
            guard let answer = answers[item.question.id] else { continue }
            insert(CheckinResponse(day: day, question: item.question, answer: answer, reason: item.reason))
        }
        try save()
    }

    /// Question id → last day it was asked, from days strictly before `day`.
    func lastAsked(before day: Date) throws -> [String: Date] {
        let rows = try fetch(FetchDescriptor<CheckinResponse>(predicate: #Predicate { $0.day < day }))
        var result: [String: Date] = [:]
        for row in rows where row.day > (result[row.questionID] ?? .distantPast) {
            result[row.questionID] = row.day
        }
        return result
    }
}
