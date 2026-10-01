import XCTest
@testable import CalmCampus

final class CheckinPlannerTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)
    private let today = Calendar(identifier: .gregorian).startOfDay(for: Date(timeIntervalSince1970: 1_790_000_000))

    private func daysAgo(_ n: Int) -> Date { calendar.date(byAdding: .day, value: -n, to: today)! }

    /// A context where nothing triggers: sleep present, no baselines, nothing asked before…
    /// except the rotating questions, which are marked as just asked so they stay quiet.
    private func quietContext() -> CheckinContext {
        CheckinContext(
            lastNightSleepHours: 7.5, sleepBaselineHours: nil,
            yesterdaySteps: 8000, stepsBaseline: nil,
            lastAsked: Dictionary(uniqueKeysWithValues: QuestionBank.rotating.map { ($0.id, daysAgo(1)) }),
            today: today)
    }

    private func ids(_ context: CheckinContext, _ answers: [String: Answer] = [:]) -> [String] {
        CheckinPlanner.plan(context: context, answers: answers, calendar: calendar).map(\.question.id)
    }

    private let coreIDs = ["mood", "energy", "stress"]

    func testQuietDayAsksOnlyCoreQuestions() {
        XCTAssertEqual(ids(quietContext()), coreIDs)
    }

    func testMissingSleepAsksForHours() {
        var context = quietContext()
        context.lastNightSleepHours = nil
        XCTAssertEqual(ids(context), coreIDs + ["sleep_hours"])
    }

    func testHighStressAsksWhatIsWeighing() {
        XCTAssertEqual(ids(quietContext(), ["stress": .scale(4)]), coreIDs + ["stressors"])
        XCTAssertEqual(ids(quietContext(), ["stress": .scale(3)]), coreIDs)
        XCTAssertEqual(ids(quietContext(), ["stress": .skipped]), coreIDs)
    }

    func testShortSleepAsksWhyOnlyOnceThereIsABaseline() {
        var context = quietContext()
        context.lastNightSleepHours = 5.5
        XCTAssertEqual(ids(context), coreIDs, "no baseline yet → no deviation questions")

        context.sleepBaselineHours = 7.5
        let plan = CheckinPlanner.plan(context: context, answers: [:], calendar: calendar)
        XCTAssertEqual(plan.map(\.question.id), coreIDs + ["sleep_disruption"])
        XCTAssertEqual(plan.last?.reason, "You slept about 2 h less than your usual 7.5 h.")

        context.lastNightSleepHours = 6.5   // only 1 h short
        XCTAssertEqual(ids(context), coreIDs)
    }

    func testQuietDayAsksAboutYesterday() {
        var context = quietContext()
        context.stepsBaseline = 8000
        context.yesterdaySteps = 3000
        XCTAssertEqual(ids(context), coreIDs + ["low_activity"])
        context.yesterdaySteps = 5000
        XCTAssertEqual(ids(context), coreIDs)
    }

    func testAtMostTwoExtraQuestions() {
        var context = quietContext()
        context.lastNightSleepHours = 5
        context.sleepBaselineHours = 7.5
        context.yesterdaySteps = 1000
        context.stepsBaseline = 8000
        XCTAssertEqual(ids(context, ["stress": .scale(5)]), coreIDs + ["stressors", "sleep_disruption"])
    }

    func testCooldownPreventsRepeats() {
        var context = quietContext()
        context.lastNightSleepHours = 5
        context.sleepBaselineHours = 7.5
        context.lastAsked["sleep_disruption"] = daysAgo(1)
        XCTAssertEqual(ids(context), coreIDs, "cooldown is 2 days")
        context.lastAsked["sleep_disruption"] = daysAgo(2)
        XCTAssertEqual(ids(context), coreIDs + ["sleep_disruption"])
    }

    func testOneRotatingQuestionNeverAskedFirst() {
        var context = quietContext()
        context.lastAsked = ["deadline_soon": daysAgo(1)]
        XCTAssertEqual(ids(context), coreIDs + ["connection"], "deadline is on cooldown; connection never asked")

        context.lastAsked = ["deadline_soon": daysAgo(10), "connection": daysAgo(8), "workload_control": daysAgo(9)]
        XCTAssertEqual(ids(context), coreIDs + ["deadline_soon"], "least recently asked wins")
    }

    func testRotatingYieldsToTargetedQuestions() {
        var context = quietContext()
        context.lastAsked = [:]
        context.lastNightSleepHours = 5
        context.sleepBaselineHours = 7.5
        XCTAssertEqual(ids(context, ["stress": .scale(5)]), coreIDs + ["stressors", "sleep_disruption"])
    }

    func testNextWalksThroughThePlanAndFinishes() {
        let context = quietContext()
        var answers: [String: Answer] = [:]
        XCTAssertEqual(CheckinPlanner.next(context: context, answers: answers)?.question.id, "mood")
        answers = ["mood": .scale(3), "energy": .skipped, "stress": .scale(4)]
        XCTAssertEqual(CheckinPlanner.next(context: context, answers: answers)?.question.id, "stressors")
        answers["stressors"] = .choices(["exams"])
        XCTAssertNil(CheckinPlanner.next(context: context, answers: answers))
    }

    func testSupportIsOfferedForLowMoodOrMaxStress() {
        XCTAssertTrue(CheckinPlanner.shouldOfferSupport(["mood": .scale(2)]))
        XCTAssertTrue(CheckinPlanner.shouldOfferSupport(["mood": .scale(4), "stress": .scale(5)]))
        XCTAssertFalse(CheckinPlanner.shouldOfferSupport(["mood": .scale(3), "stress": .scale(4)]))
        XCTAssertFalse(CheckinPlanner.shouldOfferSupport(["mood": .skipped]))
    }
}

final class CheckinContextTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testBaselineNeedsSevenDays() {
        XCTAssertNil(Baseline.median([7, 7, 7, 7, 7, 7]))
        XCTAssertEqual(Baseline.median([5, 9, 7, 6, 8, 7, 7]), 7)
        XCTAssertEqual(Baseline.median([1, 2, 3, 4, 5, 6, 7, 8]), 4.5)
    }

    func testMakeUsesOnlyEarlierDaysForBaselines() {
        let now = Date(timeIntervalSince1970: 1_790_000_000)
        let today = calendar.startOfDay(for: now)
        let summaries = (0..<10).map { offset in
            DaySummary(day: calendar.date(byAdding: .day, value: -offset, to: today)!,
                       steps: offset == 1 ? 1000 : 8000,
                       asleepHours: offset == 0 ? 5 : 7.5)
        }
        let context = CheckinContext.make(summaries: summaries, lastAsked: [:], now: now, calendar: calendar)
        XCTAssertEqual(context.lastNightSleepHours, 5)
        XCTAssertEqual(context.sleepBaselineHours, 7.5, "tonight's short sleep is not part of its own baseline")
        XCTAssertEqual(context.yesterdaySteps, 1000)
        XCTAssertEqual(context.stepsBaseline, 8000, "yesterday is not part of its own baseline")
    }

    func testSleepFromSeveralSourcesIsNotDoubleCounted() {
        let day = calendar.startOfDay(for: .now)
        let totals = SleepSegment.nightlyTotals([
            SleepSegment(day: day, source: "com.whoop", hours: 4),
            SleepSegment(day: day, source: "com.whoop", hours: 3),
            SleepSegment(day: day, source: "com.apple.health", hours: 6.5),
        ])
        XCTAssertEqual(totals[day], 7)
    }
}
