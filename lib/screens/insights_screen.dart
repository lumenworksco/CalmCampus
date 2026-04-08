import 'package:flutter/cupertino.dart';
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

    final daysWithMood = weeklyData.where((d) => d.moodRating != null).toList();

    return CupertinoScrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Large title header --
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 60, 16, 4),
              child: Text(
                'Insights',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Text(
                '7-day behavioral trends',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // -- AI Insight card -- clean white, no gradient --
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.lightbulb,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ),
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
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // -- Mood trend (only when data exists) --
            if (daysWithMood.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMoodTrend(weeklyData, labels),
            ],

            // -- Charts --
            const SizedBox(height: 8),
            TrendChart(
              title: 'Wellness Score',
              data: weeklyData.map((d) => d.wellnessScore.toDouble()).toList(),
              labels: labels,
              color: AppColors.primary,
              baselineValue: baselineMetrics.avgWellness,
            ),
            const SizedBox(height: 4),
            TrendChart(
              title: 'Sleep',
              data: weeklyData.map((d) => d.sleepHours).toList(),
              labels: labels,
              color: const Color(0xFF5856D6),
              suffix: 'h',
              baselineValue: baselineMetrics.avgSleep,
            ),
            const SizedBox(height: 4),
            TrendChart(
              title: 'Screen Time',
              data: weeklyData.map((d) => d.screenTimeHours).toList(),
              labels: labels,
              color: AppColors.warning,
              suffix: 'h',
              baselineValue: baselineMetrics.avgScreenTime,
            ),
            const SizedBox(height: 4),
            TrendChart(
              title: 'Focus Score',
              data: weeklyData
                  .map((d) =>
                      (100 - (d.appSwitches / 40 * 100)).roundToDouble())
                  .toList(),
              labels: labels,
              color: AppColors.accent,
              suffix: '%',
              baselineValue: baselineMetrics.avgFocus,
            ),

            // Bottom padding for tab bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrend(List weeklyData, List<String> labels) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(weeklyData.length, (index) {
              final day = weeklyData[index];
              final label = labels[index];
              final mood = day.moodRating;

              return SizedBox(
                width: 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (mood != null)
                      Text(
                        _moodEmojis[mood] ?? '\u{1F610}',
                        style: const TextStyle(fontSize: 24),
                      )
                    else
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.33,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
