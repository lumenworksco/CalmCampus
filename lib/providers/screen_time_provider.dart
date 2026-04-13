import 'dart:io';

import 'package:app_usage/app_usage.dart';
import 'package:flutter/foundation.dart';

/// Provides real screen-time data via the Android UsageStats API.
///
/// On iOS this is not available (Apple locks Screen Time to parental controls),
/// so [isAvailable] will remain `false` and the data engine falls back to
/// synthetic values.
class ScreenTimeProvider extends ChangeNotifier {
  double _screenTimeHours = 0;
  int _appCount = 0;
  bool _isAvailable = false;
  bool _isLoading = true;

  double get screenTimeHours => _screenTimeHours;
  int get appCount => _appCount;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    if (!Platform.isAndroid) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    await refresh();
  }

  /// Re-query today's usage stats from the system.
  Future<void> refresh() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final stats = await AppUsage().getAppUsage(startOfDay, now);

      double totalMinutes = 0;
      int activeApps = 0;
      for (final stat in stats) {
        final minutes = stat.usage.inMinutes;
        if (minutes > 0) {
          totalMinutes += minutes;
          activeApps++;
        }
      }

      _screenTimeHours = (totalMinutes / 60 * 10).round() / 10;
      _appCount = activeApps;
      _isAvailable = true;
    } catch (e) {
      debugPrint('ScreenTimeProvider: $e');
      _isAvailable = false;
    }
    _isLoading = false;
    notifyListeners();
  }
}
