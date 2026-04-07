import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/data_engine.dart';
import '../models/behavioral_signal.dart';
import '../models/wellness_anomaly.dart';
import '../providers/pedometer_provider.dart';
import '../screens/checkin_sheet.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/crisis_banner.dart';
import '../widgets/signal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/wellness_gauge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _moodEmojis = <int, String>{
    1: '\u{1F61E}',
    2: '\u{1F614}',
    3: '\u{1F610}',
    4: '\u{1F642}',
    5: '\u{1F60A}',
  };

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

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:106');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final repo = context.watch<WellnessRepository>();
    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final todayData = repo.getTodayData(realSteps: realSteps);
    final signals = getTodaySignals();
    final history = repo.getRange(7);
    final anomalies = detectAnomalies(history: history);
    final streak = repo.getStreak();
    final hasCheckin = repo.hasCheckinToday();

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

    return RefreshIndicator(
      onRefresh: () async {
        repo.refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            // Streak card
            if (streak > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: StreakCard(streakDays: streak),
              ),

            // Check-in prompt or checked-in display
            _buildCheckinSection(context, repo, hasCheckin, todayData.moodRating, todayData.energyRating),

            // Wellness Card with demo mode long-press
            Stack(
              children: [
                GestureDetector(
                  onLongPress: () => repo.toggleDemoMode(),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                ),
                // Demo badge
                if (repo.demoMode)
                  Positioned(
                    top: 24,
                    right: 28,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEMO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Crisis banner (when score < 35)
            if (todayData.wellnessScore < 35) ...[
              const SizedBox(height: 16),
              CrisisBanner(
                onTalkToSomeone: _launchPhone,
                onViewResources: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Campus wellness resources coming soon.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],

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
                  Text('\u{1F512}', style: TextStyle(fontSize: 13)),
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
      ),
    );
  }

  Widget _buildCheckinSection(
    BuildContext context,
    WellnessRepository repo,
    bool hasCheckin,
    int? moodRating,
    int? energyRating,
  ) {
    if (hasCheckin && moodRating != null) {
      // Already checked in -- show inline display
      final emoji = _moodEmojis[moodRating] ?? '\u{1F610}';
      final moodLabel = switch (moodRating) {
        1 => 'Awful',
        2 => 'Bad',
        3 => 'Okay',
        4 => 'Good',
        5 => 'Great',
        _ => '',
      };
      final energyLabel = switch (energyRating) {
        1 => 'Very low energy',
        2 => 'Low energy',
        3 => 'Moderate energy',
        4 => 'High energy',
        5 => 'Very high energy',
        _ => '',
      };

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
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feeling $moodLabel',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (energyLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      energyLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          ],
        ),
      );
    }

    // Not yet checked in -- show prompt card
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
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moodEmojis.entries.map((entry) {
              return GestureDetector(
                onTap: () => _showCheckinSheet(context, repo),
                child: Text(entry.value, style: const TextStyle(fontSize: 28)),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showCheckinSheet(context, repo),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Check in'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckinSheet(BuildContext context, WellnessRepository repo) {
    CheckinSheet.show(
      context,
      onComplete: (mood, energy) {
        repo.saveCheckin(mood: mood, energy: energy);
      },
    );
  }
}
