import 'package:flutter/cupertino.dart';
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

    final displayAnomalies = anomalies
        .where((a) =>
            a.type == AnomalyType.warning || a.type == AnomalyType.positive)
        .toList();

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

    return CupertinoScrollbar(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header --
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // -- Streak card --
                if (streak > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: StreakCard(streakDays: streak),
                  ),

                // -- Check-in section --
                _buildCheckinSection(
                  context,
                  repo,
                  hasCheckin,
                  todayData.moodRating,
                  todayData.energyRating,
                ),

                // -- Wellness gauge with demo toggle --
                Stack(
                  children: [
                    GestureDetector(
                      onLongPress: () => repo.toggleDemoMode(),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: WellnessGauge(score: todayData.wellnessScore),
                      ),
                    ),
                    // Demo dot indicator
                    if (repo.demoMode)
                      Positioned(
                        top: 26,
                        right: 30,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.warning.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // -- Crisis banner --
                if (todayData.wellnessScore < 35) ...[
                  const SizedBox(height: 16),
                  CrisisBanner(
                    onTalkToSomeone: _launchPhone,
                    onViewResources: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('Campus Resources'),
                          content: const Text(
                            'Campus wellness resources coming soon.',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],

                // -- Anomaly banners --
                if (displayAnomalies.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  for (final anomaly in displayAnomalies)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: _anomalyBorderColor(anomaly.type),
                            width: 3,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _anomalyEmoji(anomaly.type),
                              style: const TextStyle(fontSize: 16),
                            ),
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
                                      fontWeight: FontWeight.w400,
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

                // -- Signals header --
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

                // -- Signals grouped card --
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
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
                            child: Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: AppColors.border,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                // -- Privacy footer --
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.lock_fill,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'All data stays on your device',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom padding to account for tab bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1),
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
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppColors.success,
              size: 20,
            ),
          ],
        ),
      );
    }

    // Not yet checked in -- subtle prompt
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCheckinSheet(context, repo),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji faces row
              ...(_moodEmojis.values.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(e, style: const TextStyle(fontSize: 22)),
                ),
              )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Check in',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
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
