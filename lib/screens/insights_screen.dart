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
              padding: EdgeInsets.fromLTRB(20, 60, 20, 4),
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

            // -- iOS section label --
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 2, 20, 16),
              child: Text(
                '7-DAY BEHAVIORAL TRENDS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // -- AI Insight card (premium feel) --
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F0FF),
                    Color(0xFFF0F4FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8E0F0),
                  width: 0.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '\u2728',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                        const SizedBox(height: 6),
                        Text(
                          insight,
                          style: const TextStyle(
                            fontSize: 14,
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

            // -- Charts with generous spacing --
            const SizedBox(height: 8),
            TrendChart(
              title: 'Wellness Score',
              data: weeklyData.map((d) => d.wellnessScore.toDouble()).toList(),
              labels: labels,
              color: AppColors.success,
              baselineValue: baselineMetrics.avgWellness,
            ),
            const SizedBox(height: 4),
            TrendChart(
              title: 'Sleep',
              data: weeklyData.map((d) => d.sleepHours).toList(),
              labels: labels,
              color: AppColors.purple,
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
                  .map((d) => (100 - (d.appSwitches / 40 * 100)).roundToDouble())
                  .toList(),
              labels: labels,
              color: AppColors.accent,
              suffix: '%',
              baselineValue: baselineMetrics.avgFocus,
            ),

            // -- Bottom padding for tab bar --
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrend(List weeklyData, List<String> labels) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                        fontWeight: FontWeight.w500,
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
                          color: AppColors.borderLight,
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
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
