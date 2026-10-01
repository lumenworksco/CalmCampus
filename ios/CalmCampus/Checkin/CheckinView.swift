import SwiftUI

/// The daily check-in: one question per screen, every question skippable.
/// The planner is asked for the next question after each answer, so follow-ups
/// appear only when earlier answers call for them.
struct CheckinView: View {
    let context: CheckinContext
    /// Called once when the last question is answered; the caller saves.
    let onComplete: (_ planned: [PlannedQuestion], _ answers: [String: Answer]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var answers: [String: Answer] = [:]
    @State private var order: [String] = []
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Group {
                if let current = CheckinPlanner.next(context: context, answers: answers) {
                    QuestionScreen(planned: current) { answer in
                        answers[current.question.id] = answer
                        order.append(current.question.id)
                    }
                    .id(current.question.id)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                } else {
                    CompletionView(offerSupport: CheckinPlanner.shouldOfferSupport(answers)) { dismiss() }
                        .onAppear(perform: saveOnce)
                }
            }
            .animation(.snappy, value: order)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    progress
                }
                if !order.isEmpty && !saved {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Back") {
                            answers[order.removeLast()] = nil
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder private var progress: some View {
        let total = CheckinPlanner.plan(context: context, answers: answers).count
        if !saved {
            Text("\(min(order.count + 1, total)) of \(total)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func saveOnce() {
        guard !saved else { return }
        saved = true
        onComplete(CheckinPlanner.plan(context: context, answers: answers), answers)
    }
}

private struct QuestionScreen: View {
    let planned: PlannedQuestion
    let onAnswer: (Answer) -> Void

    @State private var selection: Set<String> = []
    @State private var hours: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(planned.question.prompt)
                    .font(.title.bold())
                    .fixedSize(horizontal: false, vertical: true)
                if let reason = planned.reason {
                    Text(reason)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            input

            Spacer()

            Button("Skip this question") { onAnswer(.skipped) }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
    }

    @ViewBuilder private var input: some View {
        switch planned.question.kind {
        case .scale(let spec):
            ScaleInput(spec: spec) { onAnswer(.scale($0)) }

        case .choice(let options, let multiple):
            VStack(spacing: 10) {
                ForEach(options) { option in
                    let isOn = selection.contains(option.id)
                    Button {
                        if multiple {
                            if isOn { selection.remove(option.id) } else { selection.insert(option.id) }
                        } else {
                            onAnswer(.choices([option.id]))
                        }
                    } label: {
                        HStack {
                            Text(option.label)
                            Spacer()
                            if multiple {
                                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isOn ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground),
                                    in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
                if multiple {
                    Button("Continue") { onAnswer(.choices(selection)) }
                        .buttonStyle(.borderedProminent)
                        .disabled(selection.isEmpty)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 6)
                }
            }

        case .hours(let range, let step, let initial):
            let value = hours ?? initial
            VStack(spacing: 16) {
                Text(value.formatted(.number.precision(.fractionLength(0...1))) + " h")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                Slider(value: Binding(get: { value }, set: { hours = $0 }), in: range, step: step)
                Button("Continue") { onAnswer(.hours(value)) }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ScaleInput: View {
    let spec: ScaleSpec
    let onPick: (Int) -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(Array(spec.range), id: \.self) { value in
                    Button { onPick(value) } label: {
                        Text("\(value)")
                            .font(.title2.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(value))
                }
            }
            HStack {
                Text(spec.lowLabel)
                Spacer()
                Text(spec.highLabel)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private func accessibilityLabel(_ value: Int) -> String {
        switch value {
        case spec.range.lowerBound: "\(value), \(spec.lowLabel)"
        case spec.range.upperBound: "\(value), \(spec.highLabel)"
        default: "\(value)"
        }
    }
}

private struct CompletionView: View {
    let offerSupport: Bool
    let onDone: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    Text("That's today's check-in.")
                        .font(.title2.bold())
                    Text("Thanks for taking a moment for yourself.")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            if offerSupport {
                Section {
                    SupportList()
                } header: {
                    Text("Today sounds hard. You don't have to handle it alone.")
                        .textCase(nil)
                }
            }
            Section {
                Button("Done", action: onDone)
            }
        }
    }
}
