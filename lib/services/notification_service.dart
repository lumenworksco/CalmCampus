import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/wellness_anomaly.dart';

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Owns three responsibilities:
///   1. Plugin setup and permission requests ([init]).
///   2. Scheduling the repeating daily check-in reminder.
///   3. Firing immediate nudges (anomaly + streak milestones), deduped via
///      [SharedPreferences] so the user is not spammed.
///
/// All notifications are purely local — no network calls, no remote push.
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Notification IDs — stable integers so we can cancel the right one later.
  static const int _dailyCheckinId = 1000;
  static const int _anomalyNudgeBaseId = 2000;
  static const int _streakMilestoneBaseId = 3000;

  // Android channel. Android 8+ requires a channel for every notification.
  static const AndroidNotificationChannel _mainChannel =
      AndroidNotificationChannel(
    'calm_campus_wellness',
    'Wellness reminders',
    description:
        'Daily check-ins, wellness nudges, and streak milestones from Calm Campus.',
    importance: Importance.defaultImportance,
  );

  // Preference keys for dedup and permission state.
  static const _prefAnomalyPrefix = 'notif_anomaly_'; // + anomalyId + _ + date
  static const _prefMilestonePrefix = 'notif_milestone_'; // + days
  static const _prefPermissionGranted = 'notif_permission_granted';

  bool _initialized = false;
  bool _permissionGranted = false;

  bool get isInitialized => _initialized;
  bool get hasPermission => _permissionGranted;

  /// One-time setup. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Timezone database + set local zone so zonedSchedule works.
      tzdata.initializeTimeZones();
      try {
        final localName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localName));
      } catch (e) {
        debugPrint('NotificationService: failed to resolve local timezone: $e');
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        // We explicitly request below so the iOS prompt fires on demand.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _plugin.initialize(initSettings);

      // Create the Android channel eagerly so any future notification lands in
      // the right channel regardless of entry point.
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_mainChannel);

      // Restore cached permission so the UI doesn't flash "needs permission".
      final prefs = await SharedPreferences.getInstance();
      _permissionGranted = prefs.getBool(_prefPermissionGranted) ?? false;

      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  /// Request the OS-level notification permission. Returns `true` if granted.
  ///
  /// On Android 13+ this shows the `POST_NOTIFICATIONS` dialog. On iOS it
  /// shows the standard alert/badge/sound prompt. On older Android versions
  /// notifications are granted by default.
  Future<bool> requestPermission() async {
    if (!_initialized) await init();

    bool granted = false;
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final result = await androidImpl.requestNotificationsPermission();
        // `null` on pre-13 Android = notifications are always allowed.
        granted = result ?? true;
      }

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final result = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = result ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService requestPermission failed: $e');
    }

    _permissionGranted = granted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefPermissionGranted, granted);
    notifyListeners();
    return granted;
  }

  // ---------------------------------------------------------------------------
  // Daily check-in reminder
  // ---------------------------------------------------------------------------

  /// Schedule a repeating daily reminder at [time] (local).
  Future<void> scheduleDailyCheckin(TimeOfDay time) async {
    if (!_initialized) await init();
    if (!_permissionGranted) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    await _plugin.cancel(_dailyCheckinId);

    final firstFire = _nextInstanceOf(time);

    try {
      await _plugin.zonedSchedule(
        _dailyCheckinId,
        'How are you feeling?',
        'Take a moment to check in with yourself.',
        firstFire,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _mainChannel.id,
            _mainChannel.name,
            channelDescription: _mainChannel.description,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService scheduleDailyCheckin failed: $e');
    }
  }

  Future<void> cancelDailyCheckin() async {
    if (!_initialized) await init();
    await _plugin.cancel(_dailyCheckinId);
  }

  // ---------------------------------------------------------------------------
  // Immediate nudges
  // ---------------------------------------------------------------------------

  /// Show a nudge for a freshly-detected anomaly.
  ///
  /// Dedup key: `anomaly.id + today's date`. Each anomaly fires at most once
  /// per day regardless of how many times the dashboard re-detects it.
  Future<void> showAnomalyNudge(WellnessAnomaly anomaly) async {
    if (!_initialized) await init();
    if (!_permissionGranted) return;
    if (anomaly.type != AnomalyType.warning) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefAnomalyPrefix${anomaly.id}_${_todayKey()}';
    if (prefs.getBool(key) == true) return;

    try {
      await _plugin.show(
        _anomalyNudgeBaseId + anomaly.id.hashCode.abs() % 1000,
        anomaly.title,
        anomaly.message,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _mainChannel.id,
            _mainChannel.name,
            channelDescription: _mainChannel.description,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      await prefs.setBool(key, true);
    } catch (e) {
      debugPrint('NotificationService showAnomalyNudge failed: $e');
    }
  }

  /// Celebrate crossing a streak milestone ([days] = 3, 7, 14, 30, 60, 100).
  ///
  /// Fires at most once per milestone forever — dedup key is just the day
  /// count, so the user gets exactly one "3-day streak" notification in their
  /// lifetime with the app.
  Future<void> showStreakMilestone(int days) async {
    if (!_initialized) await init();
    if (!_permissionGranted) return;

    const milestones = {3, 7, 14, 30, 60, 100};
    if (!milestones.contains(days)) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefMilestonePrefix$days';
    if (prefs.getBool(key) == true) return;

    final title = days == 3
        ? '3-day streak!'
        : days == 7
            ? 'One week strong'
            : days == 14
                ? 'Two weeks — amazing'
                : days == 30
                    ? '30-day streak!'
                    : days == 60
                        ? '60 days of care'
                        : '100 days!';
    final body = 'You\'ve kept your wellness above 70 for $days days in a row. '
        'Keep going.';

    try {
      await _plugin.show(
        _streakMilestoneBaseId + days,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _mainChannel.id,
            _mainChannel.name,
            channelDescription: _mainChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      await prefs.setBool(key, true);
    } catch (e) {
      debugPrint('NotificationService showStreakMilestone failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Bulk operations
  // ---------------------------------------------------------------------------

  /// Cancel every pending / active notification.
  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  /// Wipe the dedup log (useful for "Clear All Data" + testing).
  Future<void> clearDedupLog() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
          (k) =>
              k.startsWith(_prefAnomalyPrefix) ||
              k.startsWith(_prefMilestonePrefix),
        );
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Next occurrence of [time] in the local timezone.
  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
