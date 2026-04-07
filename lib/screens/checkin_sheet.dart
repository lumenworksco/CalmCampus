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

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required void Function(int mood, int energy) onComplete,
    int? initialMood,
    int? initialEnergy,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Daily Check-in',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Mood picker
            MoodPicker(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: 24),

            // Energy level label
            const Text(
              'Energy Level',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),

            // Energy level selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = _selectedEnergy == level;
                final isFilled =
                    _selectedEnergy != null && level <= _selectedEnergy!;

                return GestureDetector(
                  onTap: () => setState(() => _selectedEnergy = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isFilled
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isFilled
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _energyLabels[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: _canSave ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: TextButton(
                  onPressed: _canSave
                      ? () {
                          widget.onComplete(_selectedMood!, _selectedEnergy!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _canSave ? AppColors.accent : AppColors.border,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
