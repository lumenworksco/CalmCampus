import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/data_engine.dart';
import '../providers/pedometer_provider.dart';
import '../services/baseline_service.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/trend_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  static const _moodEmojis = <int, String>{
    1: '\u{1F61E}',
    2: '\u{1F614}',
    3: '\u{1F610}',
    4: '\u{1F642}',
    5: '\u{1F60A}',
  };

  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final repo = context.watch<WellnessRepository>();
    final baseline = context.read<BaselineService>();
    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final weeklyData = repo.getRange(7);
    final insight = getSmartInsight(realSteps: realSteps, history: weeklyData);
    final labels = weeklyData.map((d) => d.dayLabel).toList();
    final baselineMetrics = baseline.get7DayBaseline();

    // Check if any days have mood data
    final daysWithMood = weeklyData.where((d) => d.moodRating != null).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '7-day behavioral trends',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // AI Insight
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('\u2728', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mood trend section (only if any days have check-in data)
          if (daysWithMood.isNotEmpty)
            _buildMoodTrend(weeklyData, labels),

          // Charts with baseline values
          TrendChart(
            title: 'Wellness Score',
            data: weeklyData.map((d) => d.wellnessScore.toDouble()).toList(),
            labels: labels,
            color: AppColors.success,
            baselineValue: baselineMetrics.avgWellness,
          ),
          TrendChart(
            title: 'Sleep',
            data: weeklyData.map((d) => d.sleepHours).toList(),
            labels: labels,
            color: AppColors.purple,
            suffix: 'h',
            baselineValue: baselineMetrics.avgSleep,
          ),
          TrendChart(
            title: 'Screen Time',
            data: weeklyData.map((d) => d.screenTimeHours).toList(),
            labels: labels,
            color: AppColors.warning,
            suffix: 'h',
            baselineValue: baselineMetrics.avgScreenTime,
          ),
          TrendChart(
            title: 'Focus Score',
            data: weeklyData
                .map((d) => (100 - (d.appSwitches / 40 * 100)).roundToDouble())
                .toList(),
            labels: labels,
            color: AppColors.accent,
            suffix: '%',
            baselineValue: baselineMetrics.avgFocus,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMoodTrend(List weeklyData, List<String> labels) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Trend',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(weeklyData.length, (index) {
              final day = weeklyData[index];
              final label = labels[index];
              final mood = day.moodRating;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (mood != null)
                    Text(
                      _moodEmojis[mood] ?? '\u{1F610}',
                      style: const TextStyle(fontSize: 22),
                    )
                  else
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.borderLight,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
