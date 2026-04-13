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
  DailyData getTodayData({int? realSteps}) {
    if (!_isInitialized) {
      return data_engine.getEnhancedTodayData(realSteps: realSteps);
    }
    final dateStr = _todayStr();
    final stored = _box?.get(dateStr);

    if (stored != null) {
      var data = DailyData.fromMap(Map<String, dynamic>.from(stored as Map));
      if (realSteps != null) {
        data = data.copyWith(realSteps: realSteps);
      }
      if (_demoMode) {
        data = data.copyWith(wellnessScore: 28);
      }
      return data;
    }

    // First access: generate synthetic data and persist
    var data = data_engine.getEnhancedTodayData(realSteps: realSteps);
    _box?.put(dateStr, data.toMap());
    if (_demoMode) {
      data = data.copyWith(wellnessScore: 28);
    }
    return data;
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
