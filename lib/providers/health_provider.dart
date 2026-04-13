import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Provides real sleep data from Health Connect (Android) or HealthKit (iOS).
///
/// Queries last night's sleep duration on [init]. If the user hasn't granted
/// health permissions or no sleep data is recorded, [isAvailable] stays `false`
/// and the data engine falls back to synthetic values.
class HealthProvider extends ChangeNotifier {
  double? _sleepHours;
  bool _isAvailable = false;
  bool _isLoading = true;

  double? get sleepHours => _sleepHours;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    try {
      final health = Health();
      health.configure();

      final types = [HealthDataType.SLEEP_ASLEEP];
      final permissions = [HealthDataAccess.READ];

      final authorized = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!authorized) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Query from 8 pm yesterday to now (covers a typical sleep window).
      final now = DateTime.now();
      final yesterday8pm = DateTime(now.year, now.month, now.day - 1, 20);

      final sleepData = await health.getHealthDataFromTypes(
        types: types,
        startTime: yesterday8pm,
        endTime: now,
      );

      if (sleepData.isNotEmpty) {
        // Sum all sleep segments to get total sleep minutes.
        double totalMinutes = 0;
        for (final point in sleepData) {
          totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
        }
        _sleepHours = (totalMinutes / 60 * 10).round() / 10;
        _isAvailable = true;
      }
    } catch (e) {
      debugPrint('HealthProvider: $e');
      _isAvailable = false;
    }
    _isLoading = false;
    notifyListeners();
  }
}
