import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerProvider extends ChangeNotifier {
  static const _keyInitialSteps = 'pedometer_initial_steps';
  static const _keyStoredDate = 'pedometer_stored_date';

  int _stepsToday = 0;
  bool _isAvailable = false;
  bool _isLoading = true;
  StreamSubscription<StepCount>? _subscription;
  int? _initialSteps;
  String? _storedDate;
  Timer? _timeoutTimer;

  int get stepsToday => _stepsToday;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  void init() {
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _todayStr();
    _storedDate = prefs.getString(_keyStoredDate);
    final storedInitial = prefs.getInt(_keyInitialSteps);

    // If stored date matches today, reuse the stored initial steps
    if (_storedDate == todayStr && storedInitial != null) {
      _initialSteps = storedInitial;
    }
    // Otherwise, _initialSteps remains null and will be set from the first event

    // Start the timeout AFTER prefs load so the 3 s is measured from
    // when the subscription is actually live — not from cold app start.
    _timeoutTimer = Timer(const Duration(seconds: 3), () {
      if (_isLoading) {
        _isLoading = false;
        _isAvailable = false;
        notifyListeners();
      }
    });

    try {
      _subscription = Pedometer.stepCountStream.listen(
        (event) {
          _isAvailable = true;
          _isLoading = false;
          _timeoutTimer?.cancel();

          if (_initialSteps == null) {
            // First event for today (new day or first launch)
            _initialSteps = event.steps;
            _storedDate = todayStr;
            _persistInitialSteps(prefs, event.steps, todayStr);
          } else if (_storedDate != todayStr) {
            // Day changed since we loaded — reset for the new day
            _initialSteps = event.steps;
            _storedDate = todayStr;
            _persistInitialSteps(prefs, event.steps, todayStr);
          }

          _stepsToday = event.steps - _initialSteps!;
          notifyListeners();
        },
        onError: (error) {
          _isAvailable = false;
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _isAvailable = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _persistInitialSteps(SharedPreferences prefs, int steps, String date) {
    prefs.setInt(_keyInitialSteps, steps);
    prefs.setString(_keyStoredDate, date);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
