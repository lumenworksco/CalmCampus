import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Pomodoro-style focus timer — 25 min work / 5 min break.
class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  State<FocusTimer> createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  static const _workSeconds = 25 * 60;
  static const _breakSeconds = 5 * 60;
  static const _teal = Color(0xFF30B0C7);

  bool _isRunning = false;
  bool _isBreak = false;
  int _secondsLeft = _workSeconds;
  int _sessions = 0;
  Timer? _timer;

  int get _totalSeconds => _isBreak ? _breakSeconds : _workSeconds;
  double get _progress => 1.0 - (_secondsLeft / _totalSeconds);

  String get _timeDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _activeColor => _isBreak ? AppColors.primary : _teal;

  void _toggle() {
    if (_isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          HapticFeedback.heavyImpact();
          if (_isBreak) {
            _isBreak = false;
            _secondsLeft = _workSeconds;
          } else {
            _sessions++;
            _isBreak = true;
            _secondsLeft = _breakSeconds;
          }
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsLeft = _workSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // ---- Phase label ----
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isBreak ? 'Break Time' : 'Focus Time',
              key: ValueKey(_isBreak),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _activeColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Timer ring ----
          GestureDetector(
            onTap: _toggle,
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _progress,
                  color: _activeColor,
                  backgroundColor: AppColors.border,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeDisplay,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'tap to pause' : 'tap to start',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Session counter ----
          if (_sessions > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$_sessions session${_sessions == 1 ? '' : 's'} completed',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // ---- Reset / description ----
          if (_isRunning || _secondsLeft != _workSeconds || _isBreak)
            CupertinoButton(
              onPressed: _reset,
              padding: EdgeInsets.zero,
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '25 minutes of focused work\n5 minute break between sessions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Ring painter
// -----------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 6.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = backgroundColor,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
