import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/breathing_pattern.dart';
import '../theme/app_colors.dart';

class BreathingExercise extends StatefulWidget {
  final BreathingPattern pattern;
  const BreathingExercise({super.key, required this.pattern});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  int _currentPhaseIndex = 0;
  int _secondsLeft = 0;
  Timer? _timer;

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  BreathingPattern get _pattern => widget.pattern;

  @override
  void initState() {
    super.initState();
    _buildAnimations();
  }

  @override
  void didUpdateWidget(covariant BreathingExercise oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern.name != widget.pattern.name) {
      _stop();
      _controller.dispose();
      _buildAnimations();
    }
  }

  void _buildAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _pattern.totalDuration),
    );

    _scaleAnim = _buildScaleSequence().animate(_controller);
    _opacityAnim = _buildOpacitySequence().animate(_controller);
  }

  TweenSequence<double> _buildScaleSequence() {
    final items = <TweenSequenceItem<double>>[];
    bool lastWasExpand = false;

    for (final phase in _pattern.phases) {
      final weight = phase.durationSeconds.toDouble();

      if (phase.isExpand) {
        items.add(TweenSequenceItem(
          tween: Tween(begin: 0.6, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: weight,
        ));
        lastWasExpand = true;
      } else if (phase.isHold) {
        // Hold at whatever scale we ended on
        final holdValue = lastWasExpand ? 1.0 : 0.6;
        items.add(TweenSequenceItem(
          tween: ConstantTween(holdValue),
          weight: weight,
        ));
      } else {
        // Exhale
        items.add(TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.6)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: weight,
        ));
        lastWasExpand = false;
      }
    }

    return TweenSequence(items);
  }

  TweenSequence<double> _buildOpacitySequence() {
    final items = <TweenSequenceItem<double>>[];
    bool lastWasExpand = false;

    for (final phase in _pattern.phases) {
      final weight = phase.durationSeconds.toDouble();

      if (phase.isExpand) {
        items.add(TweenSequenceItem(
          tween: Tween(begin: 0.4, end: 1.0),
          weight: weight,
        ));
        lastWasExpand = true;
      } else if (phase.isHold) {
        final holdValue = lastWasExpand ? 1.0 : 0.4;
        items.add(TweenSequenceItem(
          tween: ConstantTween(holdValue),
          weight: weight,
        ));
      } else {
        // Exhale
        items.add(TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.4),
          weight: weight,
        ));
        lastWasExpand = false;
      }
    }

    return TweenSequence(items);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isActive = true;
      _currentPhaseIndex = 0;
      _secondsLeft = _pattern.phases[0].durationSeconds;
    });

    _controller.repeat();

    int phaseElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      phaseElapsed++;

      final currentPhase = _pattern.phases[_currentPhaseIndex];

      if (phaseElapsed >= currentPhase.durationSeconds) {
        // Move to next phase
        phaseElapsed = 0;
        final nextIndex =
            (_currentPhaseIndex + 1) % _pattern.phases.length;

        HapticFeedback.mediumImpact();

        setState(() {
          _currentPhaseIndex = nextIndex;
          _secondsLeft = _pattern.phases[nextIndex].durationSeconds;
        });
      } else {
        setState(() {
          _secondsLeft = currentPhase.durationSeconds - phaseElapsed;
        });
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    _controller.animateTo(0, duration: const Duration(milliseconds: 500));
    setState(() {
      _isActive = false;
      _currentPhaseIndex = 0;
      _secondsLeft = 0;
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
            onTap: () {
              HapticFeedback.mediumImpact();
              _isActive ? _stop() : _start();
            },
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
                                      _pattern
                                          .phases[_currentPhaseIndex].label,
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
                : '${_pattern.description}\n${_pattern.phases.map((p) => '${p.durationSeconds}s ${p.label.toLowerCase()}').join(', ')}',
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
