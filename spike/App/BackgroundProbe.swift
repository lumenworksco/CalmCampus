import BackgroundTasks
import SwiftUI

/// Q5: the MVP needs a once-a-day job (close the day, update the baseline).
/// iOS decides when app refresh runs, based on how the app is used — this
/// logs every run so we can see how often it really happens.
enum BackgroundProbe {
    static let taskID = "co.lumenworks.calmcampus.spike.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
            SpikeLog.append("background", "app refresh ran")
            schedule()
            task.setTaskCompleted(success: true)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            SpikeLog.append("background", "refresh scheduled (earliest in 1 h)")
        } catch {
            SpikeLog.append("background", "schedule failed: \(error)")
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        List {
            Section {
                Button("Schedule background refresh") { BackgroundProbe.schedule() }
                Text("Leave the app installed for a few days, open it now and then like a real user would, then check how often refresh ran.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                NavigationLink("Background log") { LogView(tag: "background") }
            }
        }
        .navigationTitle("Q5 · Background")
    }
}
