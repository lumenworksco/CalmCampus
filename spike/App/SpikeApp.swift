import SwiftUI

@main
struct SpikeApp: App {
    @StateObject private var health = HealthProbe()

    init() {
        // Both must be registered before launch finishes, or background
        // wake-ups arrive with nobody listening.
        HealthObservers.register()
        BackgroundProbe.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(health)
        }
    }
}

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Questions") {
                    NavigationLink("Q1 · HealthKit: sleep, steps, exercise") { HealthView() }
                    NavigationLink("Q2 · Sleep from motion (no watch)") { MotionSleepView() }
                    #if NO_SCREEN_TIME
                    Text("Q3 · Screen time — needs a paid team (full target)")
                        .foregroundStyle(.secondary)
                    #else
                    NavigationLink("Q3 · Screen time thresholds") { ScreenTimeView() }
                    #endif
                    NavigationLink("Q4 · On-device AI") { OnDeviceAIView() }
                    NavigationLink("Q5 · Daily background job") { BackgroundView() }
                }
                Section {
                    NavigationLink("Event log") { LogView(tag: nil) }
                }
            }
            .navigationTitle("CalmCampus Spike")
        }
    }
}

/// Newest-first view of `SpikeLog`, optionally filtered to one tag.
struct LogView: View {
    let tag: String?
    @State private var lines: [String] = []

    var body: some View {
        List(Array(lines.enumerated()), id: \.offset) { _, line in
            Text(line).font(.caption.monospaced())
        }
        .overlay { if lines.isEmpty { ContentUnavailableView("No events yet", systemImage: "tray") } }
        .navigationTitle(tag.map { "Log · \($0)" } ?? "Event log")
        .toolbar {
            ShareLink(item: lines.joined(separator: "\n"))
            Button("Clear", role: .destructive) { SpikeLog.clear(); reload() }
        }
        .onAppear(perform: reload)
        .refreshable { reload() }
    }

    private func reload() { lines = SpikeLog.entries(tag: tag) }
}
