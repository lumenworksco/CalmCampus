import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Compact streak icon
          Text(
            streakDays > 0 ? '\u{1F525}' : '\u{2B50}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: streakDays > 0
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.text,
                        letterSpacing: -0.2,
                      ),
                      children: [
                        TextSpan(
                          text: '$streakDays day streak',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(
                          text: '  '),
                        const TextSpan(
                          text: 'Wellness above 70',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'Keep wellness above 70 to start a streak',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),

          // Badge for milestones
          if (streakDays >= 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                streakDays >= 30
                    ? 'Incredible'
                    : streakDays >= 14
                        ? 'On fire'
                        : 'Amazing',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
