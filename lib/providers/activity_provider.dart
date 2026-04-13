import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks cumulative active minutes today via the Activity Recognition API.
///
/// "Active" = walking, running, or cycling. Minutes are accumulated over time
/// and persisted to SharedPreferences so they survive hot-restarts within the
/// same day.
class ActivityProvider extends ChangeNotifier {
  static const _keyDate = 'activity_date';
  static const _keyMinutes = 'activity_minutes';

  int _activeMinutes = 0;
  String _currentActivity = 'unknown';
  bool _isAvailable = false;
  bool _isLoading = true;

  StreamSubscription<Activity>? _subscription;
  DateTime? _lastActiveTimestamp;

  int get activeMinutes => _activeMinutes;
  String get currentActivity => _currentActivity;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    try {
      final ar = FlutterActivityRecognition.instance;

      // Check / request permission.
      var perm = await ar.checkPermission();
      if (perm == ActivityPermission.DENIED) {
        perm = await ar.requestPermission();
      }
      if (perm != ActivityPermission.GRANTED) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _loadStoredMinutes();

      _subscription = ar.activityStream.listen(
        (activity) {
          _isAvailable = true;
          _isLoading = false;

          final isActive = activity.type == ActivityType.WALKING ||
              activity.type == ActivityType.RUNNING ||
              activity.type == ActivityType.ON_BICYCLE;

          _currentActivity =
              activity.type.toString().split('.').last.toLowerCase();

          final now = DateTime.now();
          if (isActive && _lastActiveTimestamp != null) {
            final elapsed = now.difference(_lastActiveTimestamp!).inMinutes;
            // Only count if gap is reasonable (< 30 min) to avoid jumps.
            if (elapsed > 0 && elapsed < 30) {
              _activeMinutes += elapsed;
              _persistMinutes();
            }
          }

          _lastActiveTimestamp = isActive ? now : null;
          notifyListeners();
        },
        onError: (Object e) {
          debugPrint('ActivityProvider stream error: $e');
          _isAvailable = false;
          _isLoading = false;
          notifyListeners();
        },
      );

      // If no event arrives within 3 s, stop showing the loading state.
      Timer(const Duration(seconds: 3), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('ActivityProvider init error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadStoredMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_keyDate);
    final today = _todayStr();

    if (storedDate == today) {
      _activeMinutes = prefs.getInt(_keyMinutes) ?? 0;
    } else {
      _activeMinutes = 0;
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyMinutes, 0);
    }
  }

  Future<void> _persistMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDate, _todayStr());
    await prefs.setInt(_keyMinutes, _activeMinutes);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
