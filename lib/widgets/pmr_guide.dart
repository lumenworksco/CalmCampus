import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PMRGuide extends StatefulWidget {
  const PMRGuide({super.key});

  @override
  State<PMRGuide> createState() => _PMRGuideState();
}

class _PMRGuideState extends State<PMRGuide>
    with SingleTickerProviderStateMixin {
  static const _muscleGroups = <(String, String)>[
    ('Hands', 'Clench your fists tightly'),
    ('Arms', 'Flex your biceps'),
    ('Shoulders', 'Raise shoulders to your ears'),
    ('Face', 'Scrunch your face muscles'),
    ('Chest', 'Take a deep breath, hold it'),
    ('Legs', 'Tense your thigh muscles'),
    ('Feet', 'Curl your toes tightly'),
  ];

  static const _tenseDuration = 5;
  static const _releaseDuration = 10;

  bool _isActive = false;
  bool _isComplete = false;
  int _currentGroup = 0;
  bool _isTensePhase = true;
  int _secondsLeft = _tenseDuration;
  Timer? _timer;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.65, end: 0.55)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _tenseDuration.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: _releaseDuration.toDouble(),
      ),
    ]).animate(_controller);

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.0),
        weight: _tenseDuration.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5),
        weight: _releaseDuration.toDouble(),
      ),
    ]).animate(_controller);
  }

  void _start() {
    setState(() {
      _isActive = true;
      _isComplete = false;
      _currentGroup = 0;
      _isTensePhase = true;
      _secondsLeft = _tenseDuration;
    });

    _controller.forward(from: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsLeft--;

        if (_secondsLeft <= 0) {
          if (_isTensePhase) {
            _isTensePhase = false;
            _secondsLeft = _releaseDuration;
          } else {
            _currentGroup++;
            if (_currentGroup >= _muscleGroups.length) {
              _stop(completed: true);
              return;
            }
            _isTensePhase = true;
            _secondsLeft = _tenseDuration;
            _controller.forward(from: 0);
          }
        }
      });
    });
  }

  void _stop({bool completed = false}) {
    _timer?.cancel();
    _controller.animateTo(0, duration: const Duration(milliseconds: 500));
    setState(() {
      _isActive = false;
      _isComplete = completed;
      _currentGroup = 0;
      _isTensePhase = true;
      _secondsLeft = _tenseDuration;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color get _phaseColor =>
      _isTensePhase ? AppColors.warning : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Animated circle with gradient
          GestureDetector(
            onTap: _isActive ? _stop : _start,
            child: SizedBox(
              width: 180,
              height: 180,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = _isActive ? _scaleAnim.value : 0.6;
                  final opacity = _isActive ? _opacityAnim.value : 0.4;

                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: _isActive
                                  ? [
                                      _phaseColor.withValues(alpha: 0.18),
                                      _phaseColor.withValues(alpha: 0.08),
                                    ]
                                  : [
                                      AppColors.primary.withValues(alpha: 0.15),
                                      AppColors.primary.withValues(alpha: 0.08),
                                    ],
                            ),
                            boxShadow: _isActive
                                ? [
                                    BoxShadow(
                                      color:
                                          _phaseColor.withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _isActive ? _phaseColor : AppColors.primary,
                                  (_isActive ? _phaseColor : AppColors.primary)
                                      .withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: _isActive
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _isTensePhase
                                            ? 'Tense...'
                                            : 'Release...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$_secondsLeft',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _isComplete ? 'Done!' : 'Tap to Start',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
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

          if (_isActive) ...[
            Text(
              _muscleGroups[_currentGroup].$1,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _muscleGroups[_currentGroup].$2,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentGroup + 1} of ${_muscleGroups.length}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ] else ...[
            Text(
              _isComplete
                  ? 'Great job! Your muscles should feel relaxed.'
                  : 'Progressive Muscle Relaxation\n7 muscle groups \u2022 Tense 5s, release 10s',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_muscleGroups.length, (index) {
        Color dotColor;
        if (index < _currentGroup) {
          dotColor = AppColors.primary;
        } else if (index == _currentGroup) {
          dotColor = _phaseColor;
        } else {
          dotColor = AppColors.border;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _currentGroup ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
