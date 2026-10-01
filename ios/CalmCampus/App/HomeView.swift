import SwiftData
import SwiftUI

struct HomeView: View {
    let health: HealthSignalProvider

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CheckinResponse.day, order: .reverse) private var responses: [CheckinResponse]
    @State private var checkinContext: CheckinContext?
    @State private var isPreparing = false

    /// Days of Health data to fetch: today + up to 14 days of history for baselines.
    private static let historyDays = 15

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if checkedInToday {
                        Label("You've checked in today", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Button("Redo today's check-in", action: startCheckin)
                    } else {
                        Button(action: startCheckin) {
                            Label("Start today's check-in", systemImage: "sun.max")
                                .font(.headline)
                        }
                    }
                } footer: {
                    Text("A few quick questions. Everything stays on this iPhone.")
                }
                .disabled(isPreparing)

                if !recentDays.isEmpty {
                    Section("Last 7 days") {
                        ForEach(recentDays, id: \.day) { entry in
                            HStack {
                                Text(entry.day, format: .dateTime.weekday(.abbreviated).day())
                                    .frame(width: 64, alignment: .leading)
                                Spacer()
                                metric("Mood", entry.values[QuestionBank.mood.id])
                                metric("Energy", entry.values[QuestionBank.energy.id])
                                metric("Stress", entry.values[QuestionBank.stress.id])
                            }
                            .font(.subheadline)
                        }
                    }
                }

                Section {
                    NavigationLink("Talk to someone") { SupportView() }
                }
            }
            .navigationTitle("CalmCampus")
            .sheet(item: $checkinContext) { context in
                CheckinView(context: context) { planned, answers in
                    try? modelContext.saveCheckin(day: context.today, planned: planned, answers: answers)
                }
                .interactiveDismissDisabled()
            }
        }
    }

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    private var checkedInToday: Bool {
        responses.contains { $0.day == today }
    }

    /// Core answers for the last 7 days that have any check-in.
    private var recentDays: [(day: Date, values: [String: Double])] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -6, to: today)!
        let grouped = Dictionary(grouping: responses.filter { $0.day >= cutoff }, by: \.day)
        return grouped.keys.sorted(by: >).map { day in
            let values = grouped[day]!.reduce(into: [String: Double]()) { result, row in
                if let v = row.numericValue { result[row.questionID] = v }
            }
            return (day, values)
        }
    }

    private func metric(_ label: String, _ value: Double?) -> some View {
        VStack(spacing: 2) {
            Text(value.map { "\(Int($0))" } ?? "–").font(.headline.monospacedDigit())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(width: 52)
    }

    private func startCheckin() {
        isPreparing = true
        Task {
            await health.requestAccess()
            let summaries = await health.dailySummaries(days: Self.historyDays)
            let lastAsked = (try? modelContext.lastAsked(before: today)) ?? [:]
            checkinContext = .make(summaries: summaries, lastAsked: lastAsked)
            isPreparing = false
        }
    }
}

extension CheckinContext: Identifiable {
    var id: Date { today }
}
