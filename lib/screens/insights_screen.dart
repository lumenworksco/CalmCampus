import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/data_engine.dart';
import '../providers/pedometer_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/trend_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final weeklyData = getWeeklyData();
    final insight = getSmartInsight(realSteps: realSteps);
    final labels = weeklyData.map((d) => d.dayLabel).toList();

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
                const Text('✨', style: TextStyle(fontSize: 20)),
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

          // Charts
          TrendChart(
            title: 'Wellness Score',
            data: weeklyData.map((d) => d.wellnessScore.toDouble()).toList(),
            labels: labels,
            color: AppColors.success,
          ),
          TrendChart(
            title: 'Sleep',
            data: weeklyData.map((d) => d.sleepHours).toList(),
            labels: labels,
            color: AppColors.purple,
            suffix: 'h',
          ),
          TrendChart(
            title: 'Screen Time',
            data: weeklyData.map((d) => d.screenTimeHours).toList(),
            labels: labels,
            color: AppColors.warning,
            suffix: 'h',
          ),
          TrendChart(
            title: 'Focus Score',
            data: weeklyData
                .map((d) => (100 - (d.appSwitches / 40 * 100)).roundToDouble())
                .toList(),
            labels: labels,
            color: AppColors.accent,
            suffix: '%',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
