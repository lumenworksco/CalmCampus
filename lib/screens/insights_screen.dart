import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../data/data_engine.dart';
import '../data/mood_data.dart';
import '../navigation/tab_padding.dart';
import '../providers/activity_provider.dart';
import '../providers/health_provider.dart';
import '../providers/pedometer_provider.dart';
import '../providers/screen_time_provider.dart';
import '../services/ai_service.dart';
import '../services/baseline_service.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/trend_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _aiRequested = false;


  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final screenTimeProvider = context.watch<ScreenTimeProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final repo = context.watch<WellnessRepository>();
    final baseline = context.read<BaselineService>();

    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final realSleep = healthProvider.isAvailable ? healthProvider.sleepHours : null;
    final realScreenTime =
        screenTimeProvider.isAvailable ? screenTimeProvider.screenTimeHours : null;
    final realActiveMinutes =
        activityProvider.isAvailable ? activityProvider.activeMinutes : null;
    final realAppCount =
        screenTimeProvider.isAvailable ? screenTimeProvider.appCount : null;

    final weeklyData = repo.getRange(7);
    // Replace today's entry with real-data-enhanced version so charts and
    // insight text match the dashboard.
    if (weeklyData.isNotEmpty) {
      weeklyData[weeklyData.length - 1] = repo.getTodayData(
        realSteps: realSteps,
        realSleepHours: realSleep,
        realScreenTimeHours: realScreenTime,
        realActiveMinutes: realActiveMinutes,
        realAppCount: realAppCount,
      );
    }
    final aiService = context.watch<AiService>();
    final fallbackInsight = getSmartInsight(realSteps: realSteps, history: weeklyData);

    // Request AI insight once per screen visit.
    if (!_aiRequested && aiService.isAvailable) {
      _aiRequested = true;
      aiService.generateInsight(weeklyData, realSteps: realSteps);
    }

    final insight = aiService.cachedInsight ?? fallbackInsight;
    final labels = weeklyData.map((d) => d.dayLabel).toList();
    final baselineMetrics = baseline.get7DayBaseline();

    final daysWithMood = weeklyData.where((d) => d.moodRating != null).toList();

    final topPadding = MediaQuery.of(context).viewPadding.top;

    return CupertinoScrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Large title header --
            Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 2),
              child: const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 2, 16, 12),
              child: Text(
                '7-day behavioral trends',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // -- AI Insight card with sparkles icon --
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '✨',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        if (aiService.isGeneratingInsight && aiService.cachedInsight == null)
                          const Text(
                            'Analyzing your week...',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textTertiary,
                              height: 1.5,
                            ),
                          )
                        else
                          Text(
                            insight,
                            style: const TextStyle(
                              fontSize: 12,
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
              title: 'Active Minutes',
              data: weeklyData.map((d) => d.activeMinutes.toDouble()).toList(),
              labels: labels,
              color: AppColors.primary,
              suffix: ' min',
            ),
            const SizedBox(height: 4),
            TrendChart(
              title: 'Focus Score',
              data: weeklyData
                  .map((d) => computeFocusScore(d.appSwitches).toDouble())
                  .toList(),
              labels: labels,
              color: AppColors.accent,
              suffix: '%',
              baselineValue: baselineMetrics.avgFocus,
            ),

            // Bottom padding — native iOS tab bar height comes via
            // safe-area; Android adds the floating Flutter tab bar.
            SizedBox(height: tabBarBottomPadding(context)),
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
                        moodEmoji(mood),
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
