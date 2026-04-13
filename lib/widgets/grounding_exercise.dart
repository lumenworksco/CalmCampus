import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Interactive 5-4-3-2-1 grounding exercise (CBT technique).
///
/// The user taps once for each thing they notice through each sense,
/// progressing from 5 things they can see down to 1 thing they can taste.
class GroundingExercise extends StatefulWidget {
  const GroundingExercise({super.key});

  @override
  State<GroundingExercise> createState() => _GroundingExerciseState();
}

class _SenseStep {
  final int count;
  final String sense;
  final String verb;
  final Color color;
  const _SenseStep(this.count, this.sense, this.verb, this.color);
}

class _GroundingExerciseState extends State<GroundingExercise> {
  static const _steps = <_SenseStep>[
    _SenseStep(5, 'see', 'Look around — notice', AppColors.accent),
    _SenseStep(4, 'touch', 'Reach out and feel', AppColors.primary),
    _SenseStep(3, 'hear', 'Listen carefully for', Color(0xFF5856D6)),
    _SenseStep(2, 'smell', 'Breathe in — notice', AppColors.warning),
    _SenseStep(1, 'taste', 'Focus on', Color(0xFFFF2D55)),
  ];

  int _stepIndex = 0;
  late int _remaining;
  bool _isStarted = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _remaining = _steps[0].count;
  }

  void _tap() {
    if (_isComplete) return;

    if (!_isStarted) {
      HapticFeedback.lightImpact();
      setState(() => _isStarted = true);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _remaining--;
      if (_remaining <= 0) {
        if (_stepIndex < _steps.length - 1) {
          _stepIndex++;
          _remaining = _steps[_stepIndex].count;
          HapticFeedback.mediumImpact();
        } else {
          _isComplete = true;
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _stepIndex = 0;
      _remaining = _steps[0].count;
      _isStarted = false;
      _isComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildComplete();

    final step = _steps[_stepIndex];
    final total = step.count;

    return GestureDetector(
      onTap: _tap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // ---- Sense progress bar ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _stepIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i <= _stepIndex
                        ? _steps[i].color
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // ---- Main circle ----
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    step.color,
                    step.color.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: step.color.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isStarted
                    ? Text(
                        '$_remaining',
                        key: ValueKey('$_stepIndex-$_remaining'),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                        ),
                      )
                    : const Text(
                        'Tap',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Instruction ----
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isStarted
                    ? '${step.verb} $_remaining '
                        'thing${_remaining == 1 ? '' : 's'} '
                        'you can ${step.sense}'
                    : 'Tap the circle to begin',
                key: ValueKey('$_stepIndex-$_remaining-$_isStarted'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                  height: 1.3,
                ),
              ),
            ),

            if (_isStarted) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap each time you notice one',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),

              // ---- Item dots ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final done = i < (total - _remaining);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? step.color : CupertinoColors.white,
                      border: Border.all(
                        color: done ? step.color : AppColors.border,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- Completion view ----

  Widget _buildComplete() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Well done',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re more present now.\nCarry this awareness with you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            onPressed: _reset,
            child: const Text('Do it again'),
          ),
        ],
      ),
    );
  }
}
