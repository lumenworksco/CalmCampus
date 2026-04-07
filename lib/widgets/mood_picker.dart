import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MoodPicker extends StatelessWidget {
  final int? selectedMood; // 1-5, null = none selected
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _moods.entries.map((entry) {
        final mood = entry.key;
        final emoji = entry.value.$1;
        final label = entry.value.$2;
        final isSelected = selectedMood == mood;

        return GestureDetector(
          onTap: () => onMoodSelected(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
