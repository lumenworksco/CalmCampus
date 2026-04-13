import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

/// Three-step CBT thought record exercise.
///
/// 1. Describe the situation
/// 2. Identify the automatic thought (+ optional cognitive distortion tags)
/// 3. Reframe with a more balanced perspective
class ThoughtReframer extends StatefulWidget {
  const ThoughtReframer({super.key});

  @override
  State<ThoughtReframer> createState() => _ThoughtReframerState();
}

class _ThoughtReframerState extends State<ThoughtReframer> {
  int _step = 0; // 0 = situation, 1 = thought, 2 = reframe
  bool _isDone = false;

  final _situationCtrl = TextEditingController();
  final _thoughtCtrl = TextEditingController();
  final _reframeCtrl = TextEditingController();
  final _selectedDistortions = <String>{};

  static const _distortions = [
    'All-or-nothing',
    'Catastrophizing',
    'Mind reading',
    'Should statements',
    'Emotional reasoning',
    'Overgeneralizing',
  ];

  @override
  void dispose() {
    _situationCtrl.dispose();
    _thoughtCtrl.dispose();
    _reframeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      setState(() => _isDone = true);
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _reset() {
    setState(() {
      _step = 0;
      _isDone = false;
      _situationCtrl.clear();
      _thoughtCtrl.clear();
      _reframeCtrl.clear();
      _selectedDistortions.clear();
    });
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _situationCtrl.text.trim().isNotEmpty;
      case 1:
        return _thoughtCtrl.text.trim().isNotEmpty;
      case 2:
        return _reframeCtrl.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isDone) return _buildSummary();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Step indicator ----
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.accent : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_step + 1} of 3',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),

          // ---- Step content ----
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildStep(),
          ),
          const SizedBox(height: 24),

          // ---- Navigation ----
          Row(
            children: [
              if (_step > 0)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _back,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.chevron_left, size: 16),
                      SizedBox(width: 4),
                      Text('Back'),
                    ],
                  ),
                ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _canAdvance ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: CupertinoButton.filled(
                  onPressed: _canAdvance ? _next : null,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  child: Text(_step == 2 ? 'Done' : 'Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step content
  // ---------------------------------------------------------------------------

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildTextField(
          key: const ValueKey('step0'),
          title: 'What happened?',
          subtitle:
              'Briefly describe the situation that\'s on your mind.',
          controller: _situationCtrl,
          placeholder: 'e.g. I got a lower grade than expected...',
        );

      case 1:
        return Column(
          key: const ValueKey('step1'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              title: 'What are you telling yourself?',
              subtitle: 'Write the automatic thought that came up.',
              controller: _thoughtCtrl,
              placeholder: 'e.g. I\'m not smart enough for this...',
            ),
            const SizedBox(height: 16),
            const Text(
              'Notice any patterns? (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _distortions.map((d) {
                final selected = _selectedDistortions.contains(d);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedDistortions.remove(d);
                      } else {
                        _selectedDistortions.add(d);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.accent.withValues(alpha: 0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.accent
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 2:
        return Column(
          key: const ValueKey('step2'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show original thought for reference
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your thought:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _thoughtCtrl.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              title: 'Is that the full picture?',
              subtitle:
                  'What would you tell a friend in this situation?',
              controller: _reframeCtrl,
              placeholder: 'A more balanced way to see this...',
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Shared text field builder
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    Key? key,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          onChanged: (_) => setState(() {}),
          placeholder: placeholder,
          placeholderStyle: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 15,
          ),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
            height: 1.4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 36,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Nice work reframing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow('Situation', _situationCtrl.text),
                const SizedBox(height: 12),
                _summaryRow('Thought', _thoughtCtrl.text),
                if (_selectedDistortions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedDistortions
                        .map((d) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accent,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                const Center(
                  child: Icon(
                    CupertinoIcons.arrow_down,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                _summaryRow('Reframe', _reframeCtrl.text),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: CupertinoButton(
              onPressed: _reset,
              child: const Text('Start over'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.text,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
