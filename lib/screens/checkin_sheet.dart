import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/mood_picker.dart';

class CheckinSheet extends StatefulWidget {
  final void Function(int mood, int energy) onComplete;
  final int? initialMood;
  final int? initialEnergy;

  const CheckinSheet({
    super.key,
    required this.onComplete,
    this.initialMood,
    this.initialEnergy,
  });

  /// Shows this sheet as a Cupertino-style modal popup.
  static Future<void> show(
    BuildContext context, {
    required void Function(int mood, int energy) onComplete,
    int? initialMood,
    int? initialEnergy,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => CheckinSheet(
        onComplete: onComplete,
        initialMood: initialMood,
        initialEnergy: initialEnergy,
      ),
    );
  }

  @override
  State<CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends State<CheckinSheet> {
  late int? _selectedMood;
  late int? _selectedEnergy;

  static const _energyLabels = [
    'Very low',
    'Low',
    'Moderate',
    'High',
    'Very high',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _selectedEnergy = widget.initialEnergy;
  }

  bool get _canSave => _selectedMood != null && _selectedEnergy != null;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 14, 24, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard iOS drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7C7CC),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Daily Check-in',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 28),

              // Mood picker
              MoodPicker(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) =>
                    setState(() => _selectedMood = mood),
              ),
              const SizedBox(height: 32),

              // Energy level header
              const Text(
                'Energy Level',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),

              // Energy level selector -- filled circles with check
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = _selectedEnergy == level;
                  final isFilled =
                      _selectedEnergy != null && level <= _selectedEnergy!;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedEnergy = level),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 58,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? AppColors.accent
                                  : AppColors.background,
                              border: Border.all(
                                color: isFilled
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isFilled
                                  ? const Icon(
                                      CupertinoIcons.checkmark,
                                      size: 16,
                                      color: Colors.white,
                                      key: ValueKey('check'),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('empty'),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              letterSpacing: -0.1,
                            ),
                            child: Text(
                              _energyLabels[index],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Save button -- CupertinoButton.filled, full width
              SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  opacity: _canSave ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: CupertinoButton.filled(
                    onPressed: _canSave
                        ? () {
                            widget.onComplete(
                              _selectedMood!,
                              _selectedEnergy!,
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
