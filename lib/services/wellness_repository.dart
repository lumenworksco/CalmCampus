import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/daily_data.dart';
import '../data/data_engine.dart' as data_engine;

class WellnessRepository extends ChangeNotifier {
  static const _boxName = 'wellness_data';
  Box? _box;
  bool _demoMode = false;
  bool _isInitialized = false;

  bool get demoMode => _demoMode;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('WellnessRepository failed to open Hive box: $e');
    }
  }

  /// Toggle demo mode (overrides today's score to 28).
  void toggleDemoMode() {
    _demoMode = !_demoMode;
    notifyListeners();
  }

  /// Get today's data, generating and persisting synthetic data on first access.
  ///
  /// Real sensor values (when available) replace synthetic counterparts and the
  /// wellness score is recalculated from the (possibly real) inputs.
  DailyData getTodayData({
    int? realSteps,
    double? realSleepHours,
    double? realScreenTimeHours,
    int? realActiveMinutes,
    int? realAppCount,
  }) {
    if (!_isInitialized) {
      return data_engine.getEnhancedTodayData(
        realSteps: realSteps,
        realSleepHours: realSleepHours,
        realScreenTimeHours: realScreenTimeHours,
        realActiveMinutes: realActiveMinutes,
        realAppCount: realAppCount,
      );
    }
    final dateStr = _todayStr();
    final stored = _box?.get(dateStr);

    if (stored != null) {
      var data = DailyData.fromMap(Map<String, dynamic>.from(stored as Map));
      data = _overlayRealData(data,
        realSteps: realSteps,
        realSleepHours: realSleepHours,
        realScreenTimeHours: realScreenTimeHours,
        realActiveMinutes: realActiveMinutes,
        realAppCount: realAppCount,
      );
      if (_demoMode) data = data.copyWith(wellnessScore: 28);
      return data;
    }

    // First access: generate synthetic data and persist
    var data = data_engine.getEnhancedTodayData(
      realSteps: realSteps,
      realSleepHours: realSleepHours,
      realScreenTimeHours: realScreenTimeHours,
      realActiveMinutes: realActiveMinutes,
      realAppCount: realAppCount,
    );
    _box?.put(dateStr, data.toMap());
    if (_demoMode) data = data.copyWith(wellnessScore: 28);
    return data;
  }

  /// Overlay real sensor data onto stored [DailyData] and recalculate the
  /// wellness score so the dashboard always reflects live readings.
  DailyData _overlayRealData(
    DailyData data, {
    int? realSteps,
    double? realSleepHours,
    double? realScreenTimeHours,
    int? realActiveMinutes,
    int? realAppCount,
  }) {
    if (realSleepHours == null &&
        realScreenTimeHours == null &&
        realActiveMinutes == null &&
        realAppCount == null &&
        realSteps == null) {
      return data;
    }

    final updated = data.copyWith(
      sleepHours: realSleepHours ?? data.sleepHours,
      screenTimeHours: realScreenTimeHours ?? data.screenTimeHours,
      activeMinutes: realActiveMinutes ?? data.activeMinutes,
      appSwitches: realAppCount ?? data.appSwitches,
      realSteps: realSteps ?? data.realSteps,
    );

    final score = data_engine.calculateWellnessScore(
      updated,
      realSteps: realSteps ?? data.realSteps,
    );
    return updated.copyWith(wellnessScore: score);
  }

  /// Save check-in data (mood, energy) for today.
  Future<void> saveCheckin({required int mood, required int energy}) async {
    final dateStr = _todayStr();
    var data = getTodayData();
    data = data.copyWith(moodRating: mood, energyRating: energy);
    await _box?.put(dateStr, data.toMap());
    notifyListeners();
  }

  /// Save gratitude entry for today.
  Future<void> saveGratitude(String entry) async {
    final dateStr = _todayStr();
    var data = getTodayData();
    data = data.copyWith(gratitudeEntry: entry);
    await _box?.put(dateStr, data.toMap());
    notifyListeners();
  }

  /// Check if today has a check-in.
  bool hasCheckinToday() {
    final stored = _box?.get(_todayStr());
    if (stored == null) return false;
    return (stored as Map)['moodRating'] != null;
  }

  /// Get data for a specific date.
  DailyData? getDataForDate(String dateStr) {
    final stored = _box?.get(dateStr);
    if (stored == null) return null;
    return DailyData.fromMap(Map<String, dynamic>.from(stored as Map));
  }

  /// Get last [days] days of data (generates missing days from synthetic engine).
  List<DailyData> getRange(int days) {
    final result = <DailyData>[];
    final now = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = _formatDate(d);
      final stored = _box?.get(dateStr);
      if (stored != null) {
        result.add(DailyData.fromMap(Map<String, dynamic>.from(stored as Map)));
      } else {
        final synthetic = _generateForDate(d);
        _box?.put(dateStr, synthetic.toMap());
        result.add(synthetic);
      }
    }
    return result;
  }

  /// Get today's gratitude entry.
  String? getTodayGratitude() {
    final stored = _box?.get(_todayStr());
    if (stored == null) return null;
    return (stored as Map)['gratitudeEntry'] as String?;
  }

  /// Calculate streak (consecutive days with wellness > 70).
  int getStreak() {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final dateStr = _formatDate(d);
      final stored = _box?.get(dateStr);
      if (stored == null) break;
      final data = DailyData.fromMap(Map<String, dynamic>.from(stored as Map));
      if (data.wellnessScore > 70) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Longest consecutive run of days with wellness > 70, looking back a year.
  int getLongestStreak() {
    final box = _box;
    if (box == null) return 0;
    int longest = 0;
    int current = 0;
    final now = DateTime.now();
    for (int i = 365; i >= 0; i--) {
      final dateStr = _formatDate(now.subtract(Duration(days: i)));
      final stored = box.get(dateStr);
      if (stored == null) {
        current = 0;
        continue;
      }
      final data = DailyData.fromMap(Map<String, dynamic>.from(stored as Map));
      if (data.wellnessScore > 70) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }
    return longest;
  }

  /// Total number of days the user has completed a check-in (mood logged).
  int getTotalCheckins() {
    final box = _box;
    if (box == null) return 0;
    int count = 0;
    for (final key in box.keys) {
      final stored = box.get(key);
      if (stored is Map && stored['moodRating'] != null) count++;
    }
    return count;
  }

  /// Total number of days the user has saved a gratitude entry.
  int getTotalGratitudeEntries() {
    final box = _box;
    if (box == null) return 0;
    int count = 0;
    for (final key in box.keys) {
      final stored = box.get(key);
      if (stored is Map) {
        final entry = stored['gratitudeEntry'] as String?;
        if (entry != null && entry.trim().isNotEmpty) count++;
      }
    }
    return count;
  }

  /// Days tracked = distinct calendar days with stored data.
  int getDaysTracked() => _box?.keys.length ?? 0;

  /// Notify listeners to trigger a UI refresh.
  void refresh() {
    notifyListeners();
  }

  /// Clear all stored data.
  Future<void> clearAll() async {
    await _box?.clear();
    notifyListeners();
  }

  DailyData _generateForDate(DateTime date) => data_engine.generateForDate(date);

  String _todayStr() => _formatDate(DateTime.now());

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
