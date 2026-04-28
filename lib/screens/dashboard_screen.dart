import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/data_engine.dart';
import '../data/interventions_data.dart';
import '../data/mood_data.dart';
import '../models/behavioral_signal.dart';
import '../models/wellness_anomaly.dart';
import '../navigation/tab_padding.dart';
import '../providers/activity_provider.dart';
import '../providers/app_state.dart';
import '../providers/health_provider.dart';
import '../providers/pedometer_provider.dart';
import '../providers/screen_time_provider.dart';
import '../screens/checkin_sheet.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/crisis_banner.dart';
import '../widgets/signal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/wellness_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _anomalyRewriteRequested = false;
  int? _lastNotifiedStreak;

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

  Future<void> _launchResource(CampusResource resource) async {
    if (resource.actionUrl != null) {
      final uri = Uri.parse(resource.actionUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _showResourcesSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Campus Resources'),
        message: const Text('Support is available when you need it'),
        actions: [
          for (final resource in campusResources)
            CupertinoActionSheetAction(
              isDestructiveAction: resource.isEmergency,
              onPressed: () {
                Navigator.pop(ctx);
                _launchResource(resource);
              },
              child: Column(
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resource.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (resource.contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resource.contact!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedometer = context.watch<PedometerProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final screenTimeProvider = context.watch<ScreenTimeProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final repo = context.watch<WellnessRepository>();
    final gemini = context.watch<AiService>();

    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final realSleep = healthProvider.isAvailable ? healthProvider.sleepHours : null;
    final realScreenTime =
        screenTimeProvider.isAvailable ? screenTimeProvider.screenTimeHours : null;
    final realActiveMinutes =
        activityProvider.isAvailable ? activityProvider.activeMinutes : null;
    final realAppCount =
        screenTimeProvider.isAvailable ? screenTimeProvider.appCount : null;

    final todayData = repo.getTodayData(
      realSteps: realSteps,
      realSleepHours: realSleep,
      realScreenTimeHours: realScreenTime,
      realActiveMinutes: realActiveMinutes,
      realAppCount: realAppCount,
    );
    final signals = getTodaySignals(todayOverride: todayData);
    final history = repo.getRange(7);
    // Replace today's entry with the real-data-enhanced version so that
    // anomaly detection and the gauge use the same score.
    if (history.isNotEmpty) {
      history[history.length - 1] = todayData;
    }
    final anomalies = detectAnomalies(history: history);
    final streak = repo.getStreak();
    final hasCheckin = repo.hasCheckinToday();

    final insight = getSmartInsight(realSteps: realSteps, history: history);

    final displayAnomalies = anomalies
        .where((a) =>
            a.type == AnomalyType.warning || a.type == AnomalyType.positive)
        .toList();

    // Request AI-rewritten anomaly messages once per session.
    if (!_anomalyRewriteRequested &&
        gemini.isAvailable &&
        displayAnomalies.isNotEmpty) {
      _anomalyRewriteRequested = true;
      gemini.rewriteAnomalies(
        displayAnomalies
            .map((a) => (a.id, a.title, a.message))
            .toList(),
      );
    }

    // Fire local notifications for anomalies & streak milestones.
    // Deferred to post-frame so we never notify during a build phase.
    final appState = context.read<AppState>();
    final notif = context.read<NotificationService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dispatchNotifications(
        appState: appState,
        notif: notif,
        anomalies: anomalies,
        streak: streak,
      );
    });

    // Map signal IDs → whether they come from a live sensor.
    final liveStatus = <String, bool>{
      'sleep': healthProvider.isAvailable,
      'screen': screenTimeProvider.isAvailable,
      'movement': activityProvider.isAvailable,
      'focus': screenTimeProvider.isAvailable, // derived from app count
    };

    final allSignals = <BehavioralSignal>[
      // Steps — always visible.
      BehavioralSignal(
        id: 'steps',
        label: 'Steps',
        value: pedometer.isAvailable
            ? pedometer.stepsToday.toString()
            : '—',
        unit: pedometer.isAvailable ? 'steps' : '',
        trend: pedometer.isAvailable
            ? (pedometer.stepsToday >= 5000
                ? SignalTrend.up
                : pedometer.stepsToday >= 2000
                    ? SignalTrend.stable
                    : SignalTrend.down)
            : SignalTrend.stable,
        trendIsGood: pedometer.isAvailable && pedometer.stepsToday >= 4000,
        icon: 'steps',
        isLive: pedometer.isAvailable,
      ),
      // Remaining signals — tag each with its live status.
      for (final signal in signals)
        BehavioralSignal(
          id: signal.id,
          label: signal.label,
          value: signal.value,
          unit: signal.unit,
          trend: signal.trend,
          trendIsGood: signal.trendIsGood,
          icon: signal.icon,
          isLive: liveStatus[signal.id] ?? false,
        ),
    ];

    // viewPadding is the raw hardware safe area, never consumed by parent
    // widgets — reliably includes the Dynamic Island / notch height.
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return CupertinoScrollbar(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header --
                Padding(
                  padding: EdgeInsets.fromLTRB(16, topPadding, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: 0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(width: 8),
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
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Center(
                          child: WellnessGauge(
                              score: todayData.wellnessScore)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          insight,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // -- Crisis banner --
                if (todayData.wellnessScore < 35) ...[
                  const SizedBox(height: 16),
                  CrisisBanner(
                    onTalkToSomeone: _launchPhone,
                    onViewResources: () => _showResourcesSheet(context),
                  ),
                ],

                // -- Anomaly banners --
                if (displayAnomalies.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final anomaly in displayAnomalies)
                    Container(
                      key: ValueKey(anomaly.id),
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  anomaly.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  gemini.anomalyRewrites?[anomaly.id] ??
                                      anomaly.message,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
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
                ],

                const SizedBox(height: 10),

                // -- Signals grouped card --
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < allSignals.length; i++) ...[
                        SignalCard(key: ValueKey(allSignals[i].id), signal: allSignals[i]),
                        if (i < allSignals.length - 1)
                          const Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: AppColors.separator,
                            indent: 14,
                            endIndent: 14,
                          ),
                      ],
                    ],
                  ),
                ),

                // Bottom padding — native iOS tab bar height comes via
                // safe-area; Android adds the floating Flutter tab bar.
                SizedBox(height: tabBarBottomPadding(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dispatch any pending notifications (anomaly nudges + streak milestones).
  ///
  /// All dedup logic lives in [NotificationService] (per-anomaly-per-day,
  /// per-milestone-once), so repeatedly calling this is safe.
  void _dispatchNotifications({
    required AppState appState,
    required NotificationService notif,
    required List<WellnessAnomaly> anomalies,
    required int streak,
  }) {
    if (!appState.notificationsEnabled) return;

    if (appState.wellnessNudgesEnabled) {
      for (final a in anomalies.where((a) => a.type == AnomalyType.warning)) {
        notif.showAnomalyNudge(a);
      }
    }

    if (appState.streakMilestonesEnabled && streak != _lastNotifiedStreak) {
      _lastNotifiedStreak = streak;
      notif.showStreakMilestone(streak);
    }
  }

  Widget _buildCheckinSection(
    BuildContext context,
    WellnessRepository repo,
    bool hasCheckin,
    int? moodRating,
    int? energyRating,
  ) {
    if (hasCheckin && moodRating != null) {
      final emoji = moodEmoji(moodRating);
      final label = moodLabel(moodRating);
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
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feeling $label',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  if (energyLabel.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      energyLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.checkmark,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      );
    }

    // Not yet checked in -- row of emoji faces, subtle tap hint
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCheckinSheet(context, repo),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Emoji faces row
              ...(moodData.values.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(e.$1, style: const TextStyle(fontSize: 22)),
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
      // Return the Future so the sheet awaits Hive's write before closing —
      // this guarantees the dashboard's `hasCheckinToday()` reads the new
      // mood when the sheet pops.
      onComplete: (mood, energy) =>
          repo.saveCheckin(mood: mood, energy: energy),
    );
  }
}
