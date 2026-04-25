import 'package:flutter_test/flutter_test.dart';
import 'package:calm_campus/models/daily_data.dart';
import 'package:calm_campus/data/data_engine.dart';
import 'package:calm_campus/models/wellness_anomaly.dart';

void main() {
  // ---------------------------------------------------------------------------
  // DailyData serialisation round-trips
  // ---------------------------------------------------------------------------
  group('DailyData.toMap / fromMap', () {
    const sample = DailyData(
      date: '2026-04-25',
      dayLabel: 'Fri',
      dayOfWeek: 4,
      sleepHours: 7.5,
      screenTimeHours: 3.2,
      activeMinutes: 45,
      appSwitches: 20,
      wellnessScore: 74,
      moodRating: 4,
      energyRating: 3,
      gratitudeEntry: 'Grateful for sunshine.',
      realSteps: 8432,
    );

    test('round-trip preserves all fields', () {
      final map = sample.toMap();
      final restored = DailyData.fromMap(map);

      expect(restored.date, equals(sample.date));
      expect(restored.dayLabel, equals(sample.dayLabel));
      expect(restored.dayOfWeek, equals(sample.dayOfWeek));
      expect(restored.sleepHours, equals(sample.sleepHours));
      expect(restored.screenTimeHours, equals(sample.screenTimeHours));
      expect(restored.activeMinutes, equals(sample.activeMinutes));
      expect(restored.appSwitches, equals(sample.appSwitches));
      expect(restored.wellnessScore, equals(sample.wellnessScore));
      expect(restored.moodRating, equals(sample.moodRating));
      expect(restored.energyRating, equals(sample.energyRating));
      expect(restored.gratitudeEntry, equals(sample.gratitudeEntry));
      expect(restored.realSteps, equals(sample.realSteps));
    });

    test('round-trip with nullable fields null', () {
      const minimal = DailyData(
        date: '2026-04-25',
        dayLabel: 'Fri',
        dayOfWeek: 4,
        sleepHours: 7.0,
        screenTimeHours: 4.0,
        activeMinutes: 30,
        appSwitches: 15,
        wellnessScore: 68,
      );
      final restored = DailyData.fromMap(minimal.toMap());

      expect(restored.moodRating, isNull);
      expect(restored.energyRating, isNull);
      expect(restored.gratitudeEntry, isNull);
      expect(restored.realSteps, isNull);
    });

    test('fromMap handles legacy data missing activeMinutes', () {
      final legacyMap = sample.toMap()..remove('activeMinutes');
      final restored = DailyData.fromMap(legacyMap);
      // Legacy default is 30
      expect(restored.activeMinutes, equals(30));
    });

    test('copyWith overrides only specified fields', () {
      final modified = sample.copyWith(wellnessScore: 55, moodRating: 2);
      expect(modified.wellnessScore, equals(55));
      expect(modified.moodRating, equals(2));
      // Unchanged fields stay the same
      expect(modified.sleepHours, equals(sample.sleepHours));
      expect(modified.date, equals(sample.date));
    });
  });

  // ---------------------------------------------------------------------------
  // computeFocusScore
  // ---------------------------------------------------------------------------
  group('computeFocusScore()', () {
    test('0 switches = 100% focus', () {
      expect(computeFocusScore(0), equals(100));
    });

    test('20 switches = 50% focus', () {
      expect(computeFocusScore(20), equals(50));
    });

    test('40 switches = 0% focus', () {
      expect(computeFocusScore(40), equals(0));
    });

    test('exceeding 40 switches is clamped to 0', () {
      expect(computeFocusScore(80), equals(0));
      expect(computeFocusScore(1000), equals(0));
    });

    test('result is always in 0–100 range', () {
      for (final n in [0, 1, 10, 20, 39, 40, 41, 100]) {
        final score = computeFocusScore(n);
        expect(score, inInclusiveRange(0, 100),
            reason: 'score for $n switches was $score');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // detectAnomalies
  // ---------------------------------------------------------------------------
  group('detectAnomalies()', () {
    DailyData makeDay({
      required double sleep,
      required double screen,
      required int wellness,
      int switches = 15,
    }) =>
        DailyData(
          date: '2026-04-25',
          dayLabel: 'Fri',
          dayOfWeek: 4,
          sleepHours: sleep,
          screenTimeHours: screen,
          activeMinutes: 40,
          appSwitches: switches,
          wellnessScore: wellness,
        );

    test('returns empty list for empty history', () {
      expect(detectAnomalies(history: []), isEmpty);
    });

    test('detects low sleep anomaly', () {
      // 7-day history where today (last) has very low sleep
      final history = List.generate(
        7,
        (i) => makeDay(sleep: i < 6 ? 7.5 : 4.5, screen: 3.0, wellness: 70),
      );
      final anomalies = detectAnomalies(history: history);
      expect(anomalies.any((a) => a.metric == 'sleep'), isTrue,
          reason: 'Expected a sleep anomaly for 4.5h sleep');
    });

    test('detects high screen time anomaly', () {
      final history = List.generate(
        7,
        (i) => makeDay(sleep: 7.5, screen: i < 6 ? 3.0 : 8.5, wellness: 65),
      );
      final anomalies = detectAnomalies(history: history);
      expect(anomalies.any((a) => a.metric == 'screenTime'), isTrue,
          reason: 'Expected a screenTime anomaly for 8.5h screen time');
    });

    test('returns list of WellnessAnomaly objects', () {
      final anomalies = detectAnomalies();
      expect(anomalies, isA<List<WellnessAnomaly>>());
    });

    test('all anomaly IDs are non-empty strings', () {
      final history = List.generate(
        7,
        (i) => makeDay(sleep: i < 6 ? 7.0 : 4.0, screen: 3.0, wellness: 70),
      );
      for (final anomaly in detectAnomalies(history: history)) {
        expect(anomaly.id, isNotEmpty);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // generateForDate
  // ---------------------------------------------------------------------------
  group('generateForDate()', () {
    test('returns data for the provided date', () {
      final date = DateTime(2026, 4, 20);
      final data = generateForDate(date);
      expect(data.date, equals('2026-04-20'));
    });

    test('is deterministic for the same date', () {
      final date = DateTime(2026, 4, 18);
      final a = generateForDate(date);
      final b = generateForDate(date);
      expect(a.sleepHours, equals(b.sleepHours));
      expect(a.screenTimeHours, equals(b.screenTimeHours));
      expect(a.wellnessScore, equals(b.wellnessScore));
    });
  });
}
