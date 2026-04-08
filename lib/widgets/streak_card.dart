import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A subtle inline streak indicator -- not a card.
/// Renders as small text: "fire-emoji 7-day streak" below the date.
class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    if (streakDays <= 0) return const SizedBox.shrink();

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '\u{1F525} ',
            style: TextStyle(fontSize: 13),
          ),
          TextSpan(
            text: '$streakDays-day streak',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
