import 'package:flutter_test/flutter_test.dart';
import 'package:calm_campus/data/data_engine.dart';
import 'package:calm_campus/models/daily_data.dart';
import 'package:calm_campus/models/behavioral_signal.dart';

void main() {
  group('getTodayData()', () {
    test('returns valid DailyData with all fields', () {
      final today = getTodayData();

      expect(today, isA<DailyData>());
      expect(today.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(today.dayLabel, isNotEmpty);
      expect(today.dayOfWeek, inInclusiveRange(0, 6));
      expect(today.sleepHours, isA<double>());
      expect(today.screenTimeHours, isA<double>());
      expect(today.activeMinutes, isA<int>());
      expect(today.appSwitches, isA<int>());
      expect(today.wellnessScore, isA<int>());
    });

    test('returns deterministic data for the same date', () {
      final first = getTodayData();
      final second = getTodayData();

      expect(first.date, equals(second.date));
      expect(first.sleepHours, equals(second.sleepHours));
      expect(first.screenTimeHours, equals(second.screenTimeHours));
      expect(first.activeMinutes, equals(second.activeMinutes));
      expect(first.appSwitches, equals(second.appSwitches));
      expect(first.wellnessScore, equals(second.wellnessScore));
    });
  });

  group('getWeeklyData()', () {
    test('returns 7 entries by default', () {
      final week = getWeeklyData();
      expect(week.length, equals(7));
    });

    test('entries are in chronological order', () {
      final week = getWeeklyData();
      for (int i = 1; i < week.length; i++) {
        final prev = DateTime.parse(week[i - 1].date);
        final curr = DateTime.parse(week[i].date);
        expect(curr.isAfter(prev), isTrue,
            reason: '${week[i].date} should be after ${week[i - 1].date}');
      }
    });

    test('all wellness scores are between 10 and 98', () {
      final week = getWeeklyData();
      for (final day in week) {
        expect(day.wellnessScore, inInclusiveRange(10, 98),
            reason: 'wellnessScore ${day.wellnessScore} on ${day.date} out of range');
      }
    });

    test('all sleep hours are between 4.0 and 9.5', () {
      final week = getWeeklyData();
      for (final day in week) {
        expect(day.sleepHours, inInclusiveRange(4.0, 9.5),
            reason: 'sleepHours ${day.sleepHours} on ${day.date} out of range');
      }
    });

    test('all screen time hours are between 1.5 and 9.0', () {
      final week = getWeeklyData();
      for (final day in week) {
        expect(day.screenTimeHours, inInclusiveRange(1.5, 9.0),
            reason: 'screenTimeHours ${day.screenTimeHours} on ${day.date} out of range');
      }
    });

    test('all active minutes are between 5 and 90', () {
      final week = getWeeklyData();
      for (final day in week) {
        expect(day.activeMinutes, inInclusiveRange(5, 90),
            reason: 'activeMinutes ${day.activeMinutes} on ${day.date} out of range');
      }
    });
  });

  group('getTodaySignals()', () {
    test('returns exactly 4 signals', () {
      final signals = getTodaySignals();
      expect(signals.length, equals(4));
    });

    test('each signal has a valid trend', () {
      final signals = getTodaySignals();
      for (final signal in signals) {
        expect(signal.trend, isIn([SignalTrend.up, SignalTrend.down, SignalTrend.stable]),
            reason: 'signal ${signal.id} has unexpected trend ${signal.trend}');
      }
    });
  });

  group('getSmartInsight()', () {
    test('returns a non-empty string', () {
      final insight = getSmartInsight();
      expect(insight, isA<String>());
      expect(insight, isNotEmpty);
    });

    test('returns fallback for empty history', () {
      final insight = getSmartInsight(history: []);
      expect(insight, equals('No data available yet.'));
    });
  });
}
