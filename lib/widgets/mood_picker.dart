import 'package:flutter/material.dart';
import '../data/mood_data.dart';
import '../theme/app_colors.dart';

class MoodPicker extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodData.entries.map((entry) {
        final mood = entry.key;
        final emoji = entry.value.$1;
        final label = entry.value.$2;
        final isSelected = selectedMood == mood;

        return Semantics(
          label: 'Mood: $label',
          button: true,
          selected: isSelected,
          child: GestureDetector(
          onTap: () => onMoodSelected(mood),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji with subtle selection ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    letterSpacing: -0.1,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
        );
      }).toList(),
    );
  }
}
