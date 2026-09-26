import SwiftUI
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Q4: can the thought reframer run fully on-device (Apple Foundation Models,
/// iOS 26+, Apple Intelligence hardware only)? Measures availability, latency
/// and quality — the Flutter version sent this text to a cloud API instead.
struct OnDeviceAIView: View {
    @State private var thought = "I failed my stats exam, so I'm going to fail the whole year."
    @State private var availability = "Checking…"
    @State private var output = ""
    @State private var latency = ""
    @State private var running = false

    var body: some View {
        List {
            Section("Availability") {
                Text(availability).font(.footnote)
            }
            Section("Negative thought") {
                TextField("Thought", text: $thought, axis: .vertical)
                Button(running ? "Generating…" : "Suggest reframes on-device") {
                    Task { await run() }
                }
                .disabled(running)
            }
            if !output.isEmpty {
                Section("Result \(latency)") {
                    Text(output).font(.callout)
                }
            }
        }
        .navigationTitle("Q4 · On-device AI")
        .onAppear(perform: checkAvailability)
    }

    private func checkAvailability() {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            availability = "\(SystemLanguageModel.default.availability)"
        } else {
            availability = "Requires iOS 26 — this phone needs the non-AI fallback."
        }
        #else
        availability = "This SDK has no FoundationModels (build with Xcode 26+)."
        #endif
    }

    private func run() async {
        #if canImport(FoundationModels)
        guard #available(iOS 26, *) else { return }
        running = true
        defer { running = false }
        let session = LanguageModelSession(instructions: """
            You help university students practise CBT thought reframing. \
            Given an automatic negative thought, suggest exactly 3 brief, \
            balanced alternative thoughts, one per line, max 20 words each. \
            Be warm, not patronizing. No numbering.
            """)
        let clock = ContinuousClock()
        let start = clock.now
        do {
            let response = try await session.respond(to: thought)
            output = response.content
        } catch {
            output = "Error: \(error)"
        }
        let elapsed = clock.now - start
        latency = "(\(elapsed.formatted(.units(allowed: [.seconds, .milliseconds], width: .narrow))))"
        #endif
    }
}
