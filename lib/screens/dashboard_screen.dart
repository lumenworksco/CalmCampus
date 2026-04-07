import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/data_engine.dart';
import '../models/behavioral_signal.dart';
import '../models/wellness_anomaly.dart';
import '../providers/pedometer_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/signal_card.dart';
import '../widgets/wellness_gauge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _anomalyBorderColor(AnomalyType type) {
    switch (type) {
      case AnomalyType.warning:
        return AppColors.warning;
      case AnomalyType.positive:
        return AppColors.success;
      case AnomalyType.info:
        return AppColors.accent;
    }
  }

  Color _anomalyBackgroundColor(AnomalyType type) {
    switch (type) {
      case AnomalyType.warning:
        return AppColors.warningLight;
      case AnomalyType.positive:
        return AppColors.successLight;
      case AnomalyType.info:
        return AppColors.accentLight;
    }
  }

  String _anomalyEmoji(AnomalyType type) {
    switch (type) {
      case AnomalyType.warning:
        return '\u26A0\uFE0F';
      case AnomalyType.positive:
        return '\u2705';
      case AnomalyType.info:
        return '\u2139\uFE0F';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final todayData = getEnhancedTodayData(realSteps: realSteps);
    final signals = getTodaySignals();
    final anomalies = detectAnomalies();

    // Filter to warnings and positives for banner display
    final displayAnomalies =
        anomalies.where((a) => a.type == AnomalyType.warning || a.type == AnomalyType.positive).toList();

    final allSignals = <BehavioralSignal>[
      if (pedometer.isAvailable)
        BehavioralSignal(
          id: 'steps',
          label: 'Steps',
          value: pedometer.stepsToday.toString(),
          unit: 'steps',
          trend: pedometer.stepsToday >= 5000
              ? SignalTrend.up
              : pedometer.stepsToday >= 2000
                  ? SignalTrend.stable
                  : SignalTrend.down,
          trendIsGood: pedometer.stepsToday >= 4000,
          icon: 'steps',
          isLive: true,
        ),
      ...signals,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Wellness Card
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
            child: WellnessGauge(score: todayData.wellnessScore),
          ),

          // Anomaly banners
          if (displayAnomalies.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final anomaly in displayAnomalies)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                decoration: BoxDecoration(
                  color: _anomalyBackgroundColor(anomaly.type),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: _anomalyBorderColor(anomaly.type),
                      width: 4,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_anomalyEmoji(anomaly.type), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anomaly.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              anomaly.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // Signals
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text(
              "Today's Signals",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
              children: [
                for (int i = 0; i < allSignals.length; i++) ...[
                  SignalCard(signal: allSignals[i]),
                  if (i < allSignals.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 68),
                      child: Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                    ),
                ],
              ],
            ),
          ),

          // Privacy footer
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🔒', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Text(
                  'All data stays on your device',
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
