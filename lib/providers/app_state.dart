import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-level user preferences and profile fields.
///
/// All values are cached in [SharedPreferences] so the UI can render
/// synchronously after [init] completes on app start.
class AppState extends ChangeNotifier {
  // -- Onboarding --
  bool _hasOnboarded = false;

  // -- Profile --
  String _userName = '';
  DateTime? _memberSince;

  // -- Notification master switch (mirrors what the user sees) --
  bool _notificationsEnabled = true;

  // -- Granular notification toggles --
  bool _checkinReminderEnabled = true;
  TimeOfDay _checkinReminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _wellnessNudgesEnabled = true;
  bool _streakMilestonesEnabled = true;

  // -- Getters --
  bool get hasOnboarded => _hasOnboarded;
  String get userName => _userName;
  DateTime? get memberSince => _memberSince;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get checkinReminderEnabled => _checkinReminderEnabled;
  TimeOfDay get checkinReminderTime => _checkinReminderTime;
  bool get wellnessNudgesEnabled => _wellnessNudgesEnabled;
  bool get streakMilestonesEnabled => _streakMilestonesEnabled;

  // -- Pref keys --
  static const _kHasOnboarded = 'hasOnboarded';
  static const _kUserName = 'userName';
  static const _kMemberSince = 'memberSince';
  static const _kNotificationsEnabled = 'notificationsEnabled';
  static const _kCheckinReminderEnabled = 'checkinReminderEnabled';
  static const _kCheckinReminderHour = 'checkinReminderHour';
  static const _kCheckinReminderMinute = 'checkinReminderMinute';
  static const _kWellnessNudgesEnabled = 'wellnessNudgesEnabled';
  static const _kStreakMilestonesEnabled = 'streakMilestonesEnabled';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _hasOnboarded = prefs.getBool(_kHasOnboarded) ?? false;
    _userName = prefs.getString(_kUserName) ?? '';

    final ms = prefs.getInt(_kMemberSince);
    if (ms != null) {
      _memberSince = DateTime.fromMillisecondsSinceEpoch(ms);
    } else {
      // First launch — stamp "member since" to today.
      _memberSince = DateTime.now();
      await prefs.setInt(_kMemberSince, _memberSince!.millisecondsSinceEpoch);
    }

    _notificationsEnabled = prefs.getBool(_kNotificationsEnabled) ?? true;
    _checkinReminderEnabled = prefs.getBool(_kCheckinReminderEnabled) ?? true;
    _checkinReminderTime = TimeOfDay(
      hour: prefs.getInt(_kCheckinReminderHour) ?? 20,
      minute: prefs.getInt(_kCheckinReminderMinute) ?? 0,
    );
    _wellnessNudgesEnabled = prefs.getBool(_kWellnessNudgesEnabled) ?? true;
    _streakMilestonesEnabled = prefs.getBool(_kStreakMilestonesEnabled) ?? true;

    notifyListeners();
  }

  Future<void> setHasOnboarded(bool value) async {
    _hasOnboarded = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasOnboarded, value);
  }

  Future<void> setUserName(String value) async {
    _userName = value.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, _userName);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsEnabled, value);
  }

  Future<void> setCheckinReminderEnabled(bool value) async {
    _checkinReminderEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCheckinReminderEnabled, value);
  }

  Future<void> setCheckinReminderTime(TimeOfDay value) async {
    _checkinReminderTime = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCheckinReminderHour, value.hour);
    await prefs.setInt(_kCheckinReminderMinute, value.minute);
  }

  Future<void> setWellnessNudgesEnabled(bool value) async {
    _wellnessNudgesEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWellnessNudgesEnabled, value);
  }

  Future<void> setStreakMilestonesEnabled(bool value) async {
    _streakMilestonesEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kStreakMilestonesEnabled, value);
  }
}
