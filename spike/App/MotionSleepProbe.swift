import CoreMotion
import SwiftUI

/// Q2: can we estimate sleep for students without an Apple Watch or a sleep
/// schedule? Heuristic: the longest overnight stretch where the phone was
/// stationary (short interruptions allowed). A phone left on a desk while the
/// student is out will fool this — that's what comparing against Q1 is for.
@MainActor
final class MotionSleepProbe: ObservableObject {
    struct Night: Identifiable {
        let morning: Date
        let start: Date
        let end: Date
        var hours: Double { end.timeIntervalSince(start) / 3600 }
        var id: Date { morning }
    }

    @Published private(set) var nights: [Night] = []
    @Published private(set) var status = "Not loaded"

    private let manager = CMMotionActivityManager()
    /// Movement shorter than this doesn't break a sleep stretch (bathroom, turning over).
    private let allowedGap: TimeInterval = 10 * 60

    func load() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            status = "Motion activity not available on this device"
            return
        }
        let end = Date.now
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end)! // iOS keeps ~7 days
        manager.queryActivityStarting(from: start, to: end, to: .main) { [weak self] activities, error in
            // Delivered on the main queue, so we're on the main actor.
            MainActor.assumeIsolated {
                guard let self else { return }
                if let error {
                    self.status = "Error: \(error.localizedDescription)"
                    return
                }
                let activities = activities ?? []
                self.nights = self.estimateNights(activities, until: end)
                self.status = "\(activities.count) activity updates → \(self.nights.count) nights"
            }
        }
    }

    private func estimateNights(_ activities: [CMMotionActivity], until end: Date) -> [Night] {
        // Each activity lasts until the next one starts. Merge stationary
        // segments across short non-stationary gaps.
        var stretches: [(start: Date, end: Date)] = []
        for (i, activity) in activities.enumerated() {
            let segEnd = i + 1 < activities.count ? activities[i + 1].startDate : end
            let still = activity.stationary && !activity.walking && !activity.running
                && !activity.automotive && !activity.cycling
            guard still else { continue }
            if let last = stretches.last, activity.startDate.timeIntervalSince(last.end) <= allowedGap {
                stretches[stretches.count - 1].end = segEnd
            } else {
                stretches.append((activity.startDate, segEnd))
            }
        }

        // For each morning, take the longest stretch that ends 03:00–14:00
        // and starts after 18:00 the evening before.
        let calendar = Calendar.current
        var best: [Date: Night] = [:]
        for s in stretches {
            let morning = calendar.startOfDay(for: s.end)
            let hour = calendar.component(.hour, from: s.end)
            let eveningBefore = morning.addingTimeInterval(-6 * 3600)
            guard (3..<14).contains(hour), s.start >= eveningBefore else { continue }
            let night = Night(morning: morning, start: s.start, end: s.end)
            if night.hours > (best[morning]?.hours ?? 0) { best[morning] = night }
        }
        return best.values.sorted { $0.morning > $1.morning }
    }
}

struct MotionSleepView: View {
    @StateObject private var probe = MotionSleepProbe()
    @EnvironmentObject private var health: HealthProbe

    var body: some View {
        List {
            Section {
                Text(probe.status).font(.footnote)
                Button("Load last 7 days of motion") { probe.load() }
                if health.days.isEmpty {
                    Text("Load Q1 first to compare against HealthKit sleep.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            Section("Estimated vs HealthKit") {
                ForEach(probe.nights) { night in
                    let hk = health.days.first { $0.date == night.morning }?.asleepHours
                    VStack(alignment: .leading, spacing: 4) {
                        Text(night.morning, format: .dateTime.weekday().day().month()).bold()
                        Text("Motion: \(fmt(night.hours, "%.1f")) h "
                             + "(\(night.start.formatted(date: .omitted, time: .shortened))–"
                             + "\(night.end.formatted(date: .omitted, time: .shortened)))")
                        Text("HealthKit asleep: \(fmt(hk, "%.1f")) h")
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote)
                }
            }
        }
        .navigationTitle("Q2 · Motion sleep")
    }
}
