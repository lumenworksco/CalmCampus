import Foundation

struct SleepSegment: Equatable {
    let day: Date
    let source: String
    let hours: Double

    /// Total sleep per night. When several sources recorded the same night
    /// (Watch + WHOOP + iPhone), adding them up would double count — so per
    /// night we take the single source with the most recorded sleep.
    static func nightlyTotals(_ segments: [SleepSegment]) -> [Date: Double] {
        var perSource: [Date: [String: Double]] = [:]
        for s in segments {
            perSource[s.day, default: [:]][s.source, default: 0] += s.hours
        }
        return perSource.mapValues { $0.values.max() ?? 0 }
    }
}
