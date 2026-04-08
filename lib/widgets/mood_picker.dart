import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MoodPicker extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  static const _moods = <int, (String, String)>{
    1: ('\u{1F61E}', 'Awful'),
    2: ('\u{1F614}', 'Bad'),
    3: ('\u{1F610}', 'Okay'),
    4: ('\u{1F642}', 'Good'),
    5: ('\u{1F60A}', 'Great'),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _moods.entries.map((entry) {
        final mood = entry.key;
        final emoji = entry.value.$1;
        final label = entry.value.$2;
        final isSelected = selectedMood == mood;

        return GestureDetector(
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
        );
      }).toList(),
    );
  }
}
