import 'package:flutter/cupertino.dart';
import '../models/behavioral_signal.dart';
import '../theme/app_colors.dart';

/// Compact signal row matching the mockup:
///  [tinted icon square] [label / sub] [value / unit + trend arrow]
class SignalCard extends StatelessWidget {
  final BehavioralSignal signal;
  final String? baselineComparison;

  const SignalCard({super.key, required this.signal, this.baselineComparison});

  static const _iconConfig = <String, (IconData, Color)>{
    'steps': (CupertinoIcons.flame_fill, Color(0xFFFF9F0A)),
    'moon': (CupertinoIcons.moon_fill, Color(0xFF5856D6)),
    'phone': (CupertinoIcons.device_phone_portrait, Color(0xFFFF9F0A)),
    'walk': (CupertinoIcons.bolt_fill, AppColors.primary),
    'target': (CupertinoIcons.scope, Color(0xFF007AFF)),
  };

  @override
  Widget build(BuildContext context) {
    final config =
        _iconConfig[signal.icon] ?? (CupertinoIcons.chart_bar, const Color(0xFF8E8E93));

    // Sub-label: "Live" with green dot if live, else "Today" / "Last night" derived
    final subLabel = signal.isLive
        ? 'Live'
        : (signal.id == 'sleep'
            ? 'Last night'
            : 'Today');

    final trendIcon = signal.trend == SignalTrend.up
        ? '↑'
        : (signal.trend == SignalTrend.down ? '↓' : '→');
    final trendColor = signal.trendIsGood
        ? AppColors.primary
        : (signal.trend == SignalTrend.stable
            ? AppColors.textTertiary
            : AppColors.danger);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Tinted square icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: config.$2.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(config.$1, size: 16, color: config.$2),
          ),
          const SizedBox(width: 10),
          // Label + sub
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  signal.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Text(
                      subLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (signal.isLive) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Value + unit + trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                signal.value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Text(
                    signal.unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (signal.value != '—') ...[
                    const SizedBox(width: 4),
                    Text(
                      trendIcon,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: trendColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
