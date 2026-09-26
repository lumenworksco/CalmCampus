import DeviceActivity
import FamilyControls
import SwiftUI

/// Q3: iOS never hands screen-time numbers to the app. The only way in is to
/// register usage thresholds and have the monitor extension note which ones
/// were crossed. A ladder of thresholds (every 30 min up to 10 h) turns that
/// into "at least X h today" — this measures how reliable and timely it is.
@MainActor
final class ScreenTimeProbe: ObservableObject {
    @Published var selection: FamilyActivitySelection {
        didSet { saveSelection() }
    }
    @Published private(set) var status = ""

    static let stepMinutes = 30
    static let maxMinutes = 600
    private let activity = DeviceActivityName("daily")
    private let selectionKey = "activitySelection"

    init() {
        if let data = SpikeLog.defaults?.data(forKey: selectionKey),
           let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = saved
        } else {
            selection = FamilyActivitySelection()
        }
        refreshStatus()
    }

    var isAuthorized: Bool { AuthorizationCenter.shared.authorizationStatus == .approved }

    /// Highest threshold the extension recorded today, in minutes.
    var todayMinimumMinutes: Int {
        SpikeLog.defaults?.integer(forKey: SpikeLog.maxThresholdKey()) ?? 0
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            SpikeLog.append("screentime", "authorization failed: \(error.localizedDescription)")
        }
        refreshStatus()
    }

    func startMonitoring() {
        let events = Dictionary(uniqueKeysWithValues:
            stride(from: Self.stepMinutes, through: Self.maxMinutes, by: Self.stepMinutes).map { m in
                (DeviceActivityEvent.Name("t\(m)"),
                 DeviceActivityEvent(applications: selection.applicationTokens,
                                     categories: selection.categoryTokens,
                                     webDomains: selection.webDomainTokens,
                                     threshold: DateComponents(hour: m / 60, minute: m % 60)))
            })
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true)
        do {
            let center = DeviceActivityCenter()
            center.stopMonitoring([activity])
            try center.startMonitoring(activity, during: schedule, events: events)
            SpikeLog.append("screentime", "monitoring started with \(events.count) thresholds")
        } catch {
            SpikeLog.append("screentime", "startMonitoring failed: \(error)")
        }
        refreshStatus()
    }

    func refreshStatus() {
        let auth = switch AuthorizationCenter.shared.authorizationStatus {
        case .approved: "approved"
        case .denied: "denied"
        case .notDetermined: "not determined"
        @unknown default: "unknown"
        }
        let monitoring = DeviceActivityCenter().activities.contains(activity)
        status = "Authorization: \(auth) · Monitoring: \(monitoring ? "on" : "off") · "
            + "Selected: \(selection.categoryTokens.count) categories, "
            + "\(selection.applicationTokens.count) apps"
        objectWillChange.send()
    }

    private func saveSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            SpikeLog.defaults?.set(data, forKey: selectionKey)
        }
    }
}

struct ScreenTimeView: View {
    @StateObject private var probe = ScreenTimeProbe()
    @State private var showPicker = false

    var body: some View {
        List {
            Section {
                Text(probe.status).font(.footnote)
                Button("1 · Request Screen Time access") { Task { await probe.requestAuthorization() } }
                Button("2 · Choose what to track (select all categories)") { showPicker = true }
                    .disabled(!probe.isAuthorized)
                Button("3 · Start threshold monitoring") { probe.startMonitoring() }
                    .disabled(!probe.isAuthorized)
            }
            Section("Today") {
                let m = probe.todayMinimumMinutes
                Text(m == 0 ? "No threshold crossed yet"
                            : "At least \(m / 60) h \(m % 60) min of screen time")
                Text("Compare with Settings › Screen Time, and check the log for how late events arrive.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                NavigationLink("Threshold log") { LogView(tag: "screentime") }
            }
        }
        .navigationTitle("Q3 · Screen time")
        .familyActivityPicker(isPresented: $showPicker, selection: $probe.selection)
        .refreshable { probe.refreshStatus() }
        .onAppear { probe.refreshStatus() }
    }
}
