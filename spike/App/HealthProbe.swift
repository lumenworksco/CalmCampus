import HealthKit
import SwiftUI

/// Q1: what does HealthKit give us for the last 14 days?
@MainActor
final class HealthProbe: ObservableObject {
    struct Day: Identifiable {
        let date: Date
        var steps: Double?
        var exerciseMinutes: Double?
        var asleepHours: Double?
        var inBedHours: Double?
        var sleepSources: Set<String> = []
        var id: Date { date }
    }

    @Published private(set) var days: [Day] = []
    @Published private(set) var status = "Not requested yet"

    private let store = HKHealthStore()
    static let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.appleExerciseTime),
        HKCategoryType(.sleepAnalysis),
    ]

    func requestAndLoad() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            status = "HealthKit not available on this device"
            return
        }
        do {
            try await store.requestAuthorization(toShare: [], read: Self.readTypes)
            // The launch-time registration ran before access was granted on
            // first launch; enabling background delivery again now makes it stick.
            HealthObservers.enableBackgroundDelivery()
            try await load()
            // HealthKit never says whether *read* access was denied — a denial
            // just looks like "no data". Keep that in mind when reading results.
            status = "Loaded \(days.count) days (empty rows = no data or access denied)"
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }

    private func load() async throws {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: .now).addingTimeInterval(86_400)
        let start = calendar.date(byAdding: .day, value: -14, to: end)!
        let range = HKQuery.predicateForSamples(withStart: start, end: end)

        var byDay: [Date: Day] = [:]
        for offset in 0..<14 {
            let d = calendar.date(byAdding: .day, value: offset, to: start)!
            byDay[d] = Day(date: d)
        }

        for (type, unit, keyPath) in [
            (HKQuantityType(.stepCount), HKUnit.count(), \Day.steps),
            (HKQuantityType(.appleExerciseTime), HKUnit.minute(), \Day.exerciseMinutes),
        ] {
            let query = HKStatisticsCollectionQueryDescriptor(
                predicate: .quantitySample(type: type, predicate: range),
                options: .cumulativeSum,
                anchorDate: start,
                intervalComponents: DateComponents(day: 1))
            let collection = try await query.result(for: store)
            collection.enumerateStatistics(from: start, to: end) { stats, _ in
                if let sum = stats.sumQuantity() {
                    byDay[stats.startDate]?[keyPath: keyPath] = sum.doubleValue(for: unit)
                }
            }
        }

        // Sleep is attributed to the day you wake up. Overlapping samples from
        // several sources (Watch + iPhone + apps) would double count, so we also
        // record the sources — that itself is a finding.
        let sleepQuery = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: HKCategoryType(.sleepAnalysis), predicate: range)],
            sortDescriptors: [SortDescriptor(\.startDate)])
        let asleepValues = HKCategoryValueSleepAnalysis.allAsleepValues.map(\.rawValue)
        for sample in try await sleepQuery.result(for: store) {
            let day = calendar.startOfDay(for: sample.endDate)
            guard var entry = byDay[day] else { continue }
            let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600
            if asleepValues.contains(sample.value) {
                entry.asleepHours = (entry.asleepHours ?? 0) + hours
            } else if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                entry.inBedHours = (entry.inBedHours ?? 0) + hours
            }
            entry.sleepSources.insert(sample.sourceRevision.source.name)
            byDay[day] = entry
        }

        days = byDay.values.sorted { $0.date > $1.date }
    }
}

/// Background delivery: HealthKit wakes the app when new samples arrive.
/// Q1 also measures how often that really happens (see the log).
enum HealthObservers {
    private static let store = HKHealthStore()
    private static let types: [HKSampleType] = [HKQuantityType(.stepCount), HKCategoryType(.sleepAnalysis)]

    /// Call at launch: observer queries must exist before a background wake-up is handled.
    static func register() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completion, error in
                SpikeLog.append("health", "observer woke for \(type.identifier)"
                    + (error.map { " — error: \($0.localizedDescription)" } ?? ""))
                completion()
            }
            store.execute(query)
        }
        enableBackgroundDelivery()
    }

    static func enableBackgroundDelivery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        for type in types {
            store.enableBackgroundDelivery(for: type, frequency: .hourly) { ok, error in
                if !ok {
                    SpikeLog.append("health", "background delivery failed for \(type.identifier): "
                        + (error?.localizedDescription ?? "unknown"))
                }
            }
        }
    }
}

struct HealthView: View {
    @EnvironmentObject private var probe: HealthProbe

    var body: some View {
        List {
            Section {
                Text(probe.status).font(.footnote)
                Button("Request access & load 14 days") { Task { await probe.requestAndLoad() } }
            }
            Section("Per day (sleep = night ending that morning)") {
                ForEach(probe.days) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.date, format: .dateTime.weekday().day().month()).bold()
                        Text("Steps \(fmt(day.steps, "%.0f")) · Exercise \(fmt(day.exerciseMinutes, "%.0f")) min")
                        Text("Asleep \(fmt(day.asleepHours, "%.1f")) h · In bed \(fmt(day.inBedHours, "%.1f")) h")
                        if !day.sleepSources.isEmpty {
                            Text("Sources: \(day.sleepSources.sorted().joined(separator: ", "))")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.footnote)
                }
            }
            Section {
                NavigationLink("Background wake-ups log") { LogView(tag: "health") }
            }
        }
        .navigationTitle("Q1 · HealthKit")
    }
}

func fmt(_ value: Double?, _ format: String) -> String {
    value.map { String(format: format, $0) } ?? "—"
}
