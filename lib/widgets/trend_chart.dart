import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 7-day bar chart matching the mockup: lighter bars for past days,
/// fully-saturated bar for the most recent (today/Sunday in mockup).
class TrendChart extends StatelessWidget {
  final String title;
  final List<double> data;
  final List<String> labels;
  final Color color;
  final String suffix;
  final double? baselineValue; // unused in bar style — kept for API compat

  const TrendChart({
    super.key,
    required this.title,
    required this.data,
    required this.labels,
    this.color = AppColors.primary,
    this.suffix = '',
    this.baselineValue,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    // Baseline reference for bar opacity — span from 25% to 100%.
    // The most recent bar (last index) is always full opacity.

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < data.length; i++) ...[
                  Expanded(child: _bar(i, maxV, minV)),
                  if (i < data.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(int index, double maxV, double minV) {
    final value = data[index];
    final isLast = index == data.length - 1;
    // Height fraction: 0 → 0.18, max → 1.0
    final span = (maxV - minV) <= 0 ? 1 : (maxV - minV);
    final norm = span == 0 ? 0.5 : (value - minV) / span;
    final heightFrac = 0.25 + norm * 0.75; // keeps min bar visible
    // Opacity: lighter for past days, full for the latest bar
    final alpha = isLast ? 1.0 : 0.20 + norm * 0.40;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, c) => Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: c.maxHeight * heightFrac,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: alpha),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          labels.length > index ? labels[index] : '',
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
