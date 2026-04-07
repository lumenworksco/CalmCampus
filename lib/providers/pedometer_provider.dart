import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class PedometerProvider extends ChangeNotifier {
  int _stepsToday = 0;
  bool _isAvailable = false;
  bool _isLoading = true;
  StreamSubscription<StepCount>? _subscription;
  int? _initialSteps;

  int get stepsToday => _stepsToday;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  void init() {
    try {
      _subscription = Pedometer.stepCountStream.listen(
        (event) {
          _isAvailable = true;
          _isLoading = false;
          _initialSteps ??= event.steps;
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

    // If no event received within 3 seconds, mark as unavailable
    Future.delayed(const Duration(seconds: 3), () {
      if (_isLoading) {
        _isLoading = false;
        _isAvailable = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
