import 'package:flutter/cupertino.dart';
import '../models/behavioral_signal.dart';
import '../theme/app_colors.dart';

class SignalCard extends StatelessWidget {
  final BehavioralSignal signal;
  final String? baselineComparison;

  const SignalCard({super.key, required this.signal, this.baselineComparison});

  static const _iconConfig = <String, (IconData, Color)>{
    'steps': (CupertinoIcons.flame_fill, Color(0xFFFF9F0A)),
    'moon': (CupertinoIcons.moon_fill, Color(0xFF5856D6)),
    'phone': (CupertinoIcons.device_phone_portrait, Color(0xFF8E8E93)),
    'walk': (CupertinoIcons.bolt_fill, AppColors.primary),
    'target': (CupertinoIcons.scope, Color(0xFF007AFF)),
  };

  @override
  Widget build(BuildContext context) {
    final config =
        _iconConfig[signal.icon] ?? (CupertinoIcons.chart_bar, const Color(0xFF8E8E93));
    final trendColor = signal.trendIsGood ? AppColors.primary : AppColors.danger;
    final trendLabel = signal.trendIsGood
        ? (signal.trend == SignalTrend.stable ? 'Stable' : 'Good')
        : (signal.trend == SignalTrend.stable ? 'Stable' : 'Attention');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon in subtle tinted circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config.$2.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(config.$1, size: 18, color: config.$2),
                // Tiny pulsing green dot for live signals
                if (signal.isLive)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
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
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      ' ${signal.unit}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Trend or "Estimated" label
          if (signal.isLive)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: trendColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                signal.value == '—' ? 'Unavailable' : 'Estimated',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
