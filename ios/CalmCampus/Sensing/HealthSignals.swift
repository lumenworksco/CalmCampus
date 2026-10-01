import Foundation
import HealthKit

/// Source of daily passive signals. Behind a protocol so the check-in can be
/// tested (and run in the simulator) without Apple Health data.
protocol HealthSignalProvider {
    func requestAccess() async
    /// One summary per day for the last `days` days, including today.
    func dailySummaries(days: Int) async -> [DaySummary]
}

/// Only steps and sleep: the spike showed exercise minutes are too patchy
/// without an Apple Watch, and motion-based sleep estimates are unusable.
final class HealthKitSignals: HealthSignalProvider {
    private let store = HKHealthStore()
    private let steps = HKQuantityType(.stepCount)
    private let sleep = HKCategoryType(.sleepAnalysis)

    func requestAccess() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try? await store.requestAuthorization(toShare: [], read: [steps, sleep])
    }

    func dailySummaries(days: Int) async -> [DaySummary] {
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        let calendar = Calendar.current
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now))!
        let start = calendar.date(byAdding: .day, value: -days, to: end)!
        let range = HKQuery.predicateForSamples(withStart: start, end: end)

        var byDay: [Date: DaySummary] = [:]
        for offset in 0..<days {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            byDay[day] = DaySummary(day: day)
        }

        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: .quantitySample(type: steps, predicate: range),
            options: .cumulativeSum, anchorDate: start, intervalComponents: DateComponents(day: 1))
        if let collection = try? await stepsQuery.result(for: store) {
            collection.enumerateStatistics(from: start, to: end) { stats, _ in
                if let sum = stats.sumQuantity() {
                    byDay[stats.startDate]?.steps = Int(sum.doubleValue(for: .count()))
                }
            }
        }

        let sleepQuery = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleep, predicate: range)],
            sortDescriptors: [SortDescriptor(\.startDate)])
        if let samples = try? await sleepQuery.result(for: store) {
            let asleep = Set(HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue))
            let segments = samples.filter { asleep.contains($0.value) }.map {
                SleepSegment(day: calendar.startOfDay(for: $0.endDate),
                             source: $0.sourceRevision.source.bundleIdentifier,
                             hours: $0.endDate.timeIntervalSince($0.startDate) / 3600)
            }
            for (day, hours) in SleepSegment.nightlyTotals(segments) where byDay[day] != nil {
                byDay[day]?.asleepHours = hours
            }
        }

        return byDay.values.sorted { $0.day < $1.day }
    }
}

/// For the simulator and previews: no Health data at all, like a student
/// without a wearable on day one.
struct NoHealthSignals: HealthSignalProvider {
    func requestAccess() async {}
    func dailySummaries(days: Int) async -> [DaySummary] { [] }
}
