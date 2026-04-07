import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  static const _phases = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];
  static const _phaseDuration = 4; // seconds

  bool _isActive = false;
  int _currentPhase = 0;
  int _secondsLeft = 4;
  Timer? _timer;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16), // 4 phases × 4 seconds
    );

    // Scale: 0.6 → 1.0 (breathe in), hold, 1.0 → 0.6 (breathe out), hold
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.6), weight: 1),
    ]).animate(_controller);

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.4), weight: 1),
    ]).animate(_controller);
  }

  void _start() {
    setState(() {
      _isActive = true;
      _currentPhase = 0;
      _secondsLeft = _phaseDuration;
    });

    _controller.repeat();

    int tick = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      tick++;
      setState(() {
        _currentPhase = (tick ~/ _phaseDuration) % 4;
        _secondsLeft = _phaseDuration - (tick % _phaseDuration);
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _controller.animateTo(0, duration: const Duration(milliseconds: 500));
    setState(() {
      _isActive = false;
      _currentPhase = 0;
      _secondsLeft = _phaseDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isActive ? _stop : _start,
            child: SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isActive ? _scaleAnim.value : 0.6,
                    child: Opacity(
                      opacity: _isActive ? _opacityAnim.value : 0.4,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          alignment: Alignment.center,
                          child: _isActive
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _phases[_currentPhase],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_secondsLeft',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Tap to Start',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isActive
                ? 'Tap the circle to stop'
                : 'Box breathing: 4s in, hold, out, hold.\nActivates your parasympathetic nervous system.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
