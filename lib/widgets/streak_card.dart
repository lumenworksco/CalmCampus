import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Compact streak indicator rendered as a small orange pill,
/// matching the mockup:  🔥 4 days
class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    if (streakDays <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '\u{1F525} ',
              style: TextStyle(fontSize: 11),
            ),
            TextSpan(
              text: '$streakDays days',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
