import Foundation

/// One day of passive signals. `nil` always means "no data", never zero.
struct DaySummary: Equatable {
    let day: Date          // start of day
    var steps: Int?
    var asleepHours: Double?  // the night that ended that morning
}

/// Everything the planner needs to know, gathered up front so the planner
/// itself stays a pure, testable function.
struct CheckinContext: Equatable {
    var lastNightSleepHours: Double?
    var sleepBaselineHours: Double?
    var yesterdaySteps: Int?
    var stepsBaseline: Int?
    /// Question id → the last day it was asked (answered or skipped).
    var lastAsked: [String: Date]
    var today: Date

    /// Build the context from daily summaries (any order) and the ask history.
    /// Baselines use only days *before* the one being compared, and only once
    /// there are enough real days — no baseline beats a made-up one.
    static func make(summaries: [DaySummary], lastAsked: [String: Date],
                     now: Date = .now, calendar: Calendar = .current) -> CheckinContext {
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let byDay = Dictionary(summaries.map { ($0.day, $0) }, uniquingKeysWith: { a, _ in a })

        let sleepHistory = summaries.filter { $0.day < today }.compactMap(\.asleepHours)
        let stepsHistory = summaries.filter { $0.day < yesterday }.compactMap(\.steps).map(Double.init)

        return CheckinContext(
            lastNightSleepHours: byDay[today]?.asleepHours,
            sleepBaselineHours: Baseline.median(sleepHistory),
            yesterdaySteps: byDay[yesterday]?.steps,
            stepsBaseline: Baseline.median(stepsHistory).map { Int($0.rounded()) },
            lastAsked: lastAsked,
            today: today)
    }
}

enum Baseline {
    /// Minimum number of real days before we compare against "usual".
    static let minimumDays = 7

    static func median(_ values: [Double]) -> Double? {
        guard values.count >= minimumDays else { return nil }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        return sorted.count.isMultiple(of: 2) ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid]
    }
}
