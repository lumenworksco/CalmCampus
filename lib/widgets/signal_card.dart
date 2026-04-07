import 'package:flutter/material.dart';
import '../models/behavioral_signal.dart';
import '../theme/app_colors.dart';

class SignalCard extends StatelessWidget {
  final BehavioralSignal signal;
  final String? baselineComparison;

  const SignalCard({super.key, required this.signal, this.baselineComparison});

  static const _iconConfig = <String, (String, Color)>{
    'steps': ('🚶', AppColors.successLight),
    'moon': ('🌙', AppColors.purpleLight),
    'phone': ('📱', AppColors.warningLight),
    'keyboard': ('⌨️', AppColors.accentLight),
    'target': ('🎯', AppColors.dangerLight),
  };

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig[signal.icon] ?? ('📊', const Color(0xFFF5F5F5));
    final trendColor = signal.trendIsGood ? AppColors.success : AppColors.danger;
    final trendLabel = signal.trendIsGood
        ? (signal.trend == SignalTrend.stable ? 'Stable' : 'Good')
        : (signal.trend == SignalTrend.stable ? 'Stable' : 'Needs attention');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: config.$2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(config.$1, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      signal.label,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (signal.isLive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      signal.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      ' ${signal.unit}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trendLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
              if (baselineComparison != null)
                Text(
                  baselineComparison!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
