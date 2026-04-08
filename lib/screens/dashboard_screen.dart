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

  Color _anomalyDotColor(AnomalyType type) {
    switch (type) {
      case AnomalyType.warning:
        return AppColors.warning;
      case AnomalyType.positive:
        return AppColors.primary;
      case AnomalyType.info:
        return AppColors.accent;
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
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
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
                      Row(
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(width: 12),
                            StreakCard(streakDays: streak),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // -- Check-in section --
                _buildCheckinSection(
                  context,
                  repo,
                  hasCheckin,
                  todayData.moodRating,
                  todayData.energyRating,
                ),

                // -- Wellness gauge --
                GestureDetector(
                  onLongPress: () => repo.toggleDemoMode(),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                            child: WellnessGauge(
                                score: todayData.wellnessScore)),
                        if (repo.demoMode)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                  const SizedBox(height: 20),
                  for (final anomaly in displayAnomalies)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Small colored dot instead of emoji
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _anomalyDotColor(anomaly.type),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anomaly.title,
                                  style: const TextStyle(
                                    fontSize: 15,
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
                ],

                const SizedBox(height: 20),

                // -- Signals grouped card (no header text) --
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < allSignals.length; i++) ...[
                        SignalCard(signal: allSignals[i]),
                        if (i < allSignals.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 64),
                            child: Divider(
                              height: 0.33,
                              thickness: 0.33,
                              color: AppColors.separator,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                // Bottom padding for tab bar
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
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
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
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      );
    }

    // Not yet checked in -- row of emoji faces, subtle tap hint
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCheckinSheet(context, repo),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
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
              const Text(
                'How are you?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: AppColors.textTertiary,
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
