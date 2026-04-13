import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/interventions_data.dart';
import '../models/breathing_pattern.dart';
import '../models/daily_data.dart';
import '../providers/activity_provider.dart';
import '../providers/health_provider.dart';
import '../providers/pedometer_provider.dart';
import '../providers/screen_time_provider.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_exercise.dart';
import '../widgets/focus_timer.dart';
import '../widgets/gratitude_journal.dart';
import '../widgets/grounding_exercise.dart';
import '../widgets/pmr_guide.dart';
import '../widgets/thought_reframer.dart';

// =============================================================================
// Private data types
// =============================================================================

class _ToolInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  const _ToolInfo(this.id, this.name, this.description, this.icon, this.color);
}

class _Recommendation {
  final String toolId;
  final String title;
  final String reason;
  final IconData icon;
  final Color color;
  const _Recommendation(
      this.toolId, this.title, this.reason, this.icon, this.color);
}

// =============================================================================
// Tool catalogue
// =============================================================================

const _tools = <_ToolInfo>[
  _ToolInfo('breathe', 'Breathe', 'Guided breathing exercises',
      CupertinoIcons.wind, AppColors.primary),
  _ToolInfo('ground', 'Ground', '5-4-3-2-1 senses exercise',
      CupertinoIcons.leaf_arrow_circlepath, Color(0xFF5856D6)),
  _ToolInfo('reframe', 'Reframe', 'Challenge unhelpful thoughts',
      CupertinoIcons.lightbulb_fill, AppColors.accent),
  _ToolInfo('relax', 'Body Relax', 'Progressive muscle relaxation',
      CupertinoIcons.hand_raised_fill, AppColors.warning),
  _ToolInfo('gratitude', 'Gratitude', 'Daily thankfulness journal',
      CupertinoIcons.heart_fill, Color(0xFFFF2D55)),
  _ToolInfo('focus', 'Focus', 'Pomodoro focus timer', CupertinoIcons.timer,
      Color(0xFF30B0C7)),
];

// =============================================================================
// Toolkit Screen
// =============================================================================

class ToolkitScreen extends StatelessWidget {
  const ToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final repo = context.watch<WellnessRepository>();
    final pedometer = context.watch<PedometerProvider>();
    final healthProvider = context.watch<HealthProvider>();
    final screenTimeProvider = context.watch<ScreenTimeProvider>();
    final activityProvider = context.watch<ActivityProvider>();

    final realSteps = pedometer.isAvailable ? pedometer.stepsToday : null;
    final realSleep = healthProvider.isAvailable ? healthProvider.sleepHours : null;
    final realScreenTime =
        screenTimeProvider.isAvailable ? screenTimeProvider.screenTimeHours : null;
    final realActiveMinutes =
        activityProvider.isAvailable ? activityProvider.activeMinutes : null;
    final realAppCount =
        screenTimeProvider.isAvailable ? screenTimeProvider.appCount : null;

    final data = repo.getTodayData(
      realSteps: realSteps,
      realSleepHours: realSleep,
      realScreenTimeHours: realScreenTime,
      realActiveMinutes: realActiveMinutes,
      realAppCount: realAppCount,
    );
    final recs = _getRecommendations(data);

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topPad + 16, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header ----
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Toolkit',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Evidence-based tools for your wellbeing',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---- For You ----
          if (recs.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'For You',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (ctx, i) => _RecommendationCard(
                  rec: recs[i],
                  onTap: () => _openTool(ctx, recs[i].toolId, repo),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ---- All Tools ----
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'All Tools',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ToolsGrid(onTap: (id) => _openTool(context, id, repo)),
          const SizedBox(height: 28),

          // ---- Campus Support ----
          _CampusSupportCard(onTap: () => _showResources(context)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recommendation engine
  // ---------------------------------------------------------------------------

  List<_Recommendation> _getRecommendations(DailyData data) {
    final recs = <_Recommendation>[];

    if (data.moodRating != null && data.moodRating! <= 2) {
      recs.add(const _Recommendation(
        'ground',
        'Ground yourself',
        'Reconnect with your senses when feeling low',
        CupertinoIcons.leaf_arrow_circlepath,
        Color(0xFF5856D6),
      ));
    }

    if (data.wellnessScore < 50) {
      recs.add(const _Recommendation(
        'breathe',
        'Take a breath',
        'Your wellness score is below average today',
        CupertinoIcons.wind,
        AppColors.primary,
      ));
    }

    if (data.sleepHours < 6) {
      recs.add(const _Recommendation(
        'relax',
        'Relax your body',
        'Low sleep — release built-up tension',
        CupertinoIcons.hand_raised_fill,
        AppColors.warning,
      ));
    }

    if (data.screenTimeHours > 6) {
      recs.add(const _Recommendation(
        'focus',
        'Try a focus session',
        'High screen time — try structured focus blocks',
        CupertinoIcons.timer,
        Color(0xFF30B0C7),
      ));
    }

    // Fallback: suggest gratitude (if empty) + breathing
    if (recs.isEmpty) {
      if (data.gratitudeEntry == null || data.gratitudeEntry!.isEmpty) {
        recs.add(const _Recommendation(
          'gratitude',
          'Write gratitude',
          'Start your day with a positive reflection',
          CupertinoIcons.heart_fill,
          Color(0xFFFF2D55),
        ));
      }
      recs.add(const _Recommendation(
        'breathe',
        'Quick breathing',
        'A moment of calm to center yourself',
        CupertinoIcons.wind,
        AppColors.primary,
      ));
    }

    return recs.take(2).toList();
  }

  // ---------------------------------------------------------------------------
  // Open a tool in a bottom sheet
  // ---------------------------------------------------------------------------

  void _openTool(
    BuildContext context,
    String id,
    WellnessRepository repo,
  ) {
    String title;
    Widget child;

    switch (id) {
      case 'breathe':
        title = 'Breathe';
        child = const _BreathingContent();
      case 'ground':
        title = 'Ground';
        child = const GroundingExercise();
      case 'reframe':
        title = 'Reframe';
        child = const ThoughtReframer();
      case 'relax':
        title = 'Body Relax';
        child = const PMRGuide();
      case 'gratitude':
        title = 'Gratitude';
        child = GratitudeJournal(
          existingEntry: repo.getTodayGratitude(),
          onSave: repo.saveGratitude,
        );
      case 'focus':
        title = 'Focus';
        child = const FocusTimer();
      default:
        return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ToolSheet(title: title, child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // Campus resources sheet
  // ---------------------------------------------------------------------------

  void _showResources(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ResourcesSheet(),
    );
  }
}

// =============================================================================
// Sub-widgets
// =============================================================================

// ---- Recommendation card (horizontal scroll) --------------------------------

class _RecommendationCard extends StatelessWidget {
  final _Recommendation rec;
  final VoidCallback onTap;
  const _RecommendationCard({required this.rec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rec.color.withValues(alpha: 0.10),
              rec.color.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rec.color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(rec.icon, size: 18, color: rec.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: rec.color,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: rec.color.withValues(alpha: 0.6),
                ),
              ],
            ),
            const Spacer(),
            Text(
              rec.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Tools grid (2 columns) -------------------------------------------------

class _ToolsGrid extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _ToolsGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
        children: _tools
            .map((t) => _ToolCard(tool: t, onTap: () => onTap(t.id)))
            .toList(),
      ),
    );
  }
}

// ---- Single tool card -------------------------------------------------------

class _ToolCard extends StatelessWidget {
  final _ToolInfo tool;
  final VoidCallback onTap;
  const _ToolCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, size: 18, color: tool.color),
            ),
            const Spacer(),
            Text(
              tool.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tool.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Tool sheet shell -------------------------------------------------------

class _ToolSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _ToolSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7C7CC),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppColors.textTertiary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 40 + keyboardInset),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Campus support card ----------------------------------------------------

class _CampusSupportCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CampusSupportCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  CupertinoIcons.heart_fill,
                  size: 20,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I Need Help Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Campus support & crisis resources',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Resources sheet --------------------------------------------------------

class _ResourcesSheet extends StatelessWidget {
  const _ResourcesSheet();

  @override
  Widget build(BuildContext context) {
    final emergency =
        campusResources.where((r) => r.isEmergency).toList();
    final others =
        campusResources.where((r) => !r.isEmergency).toList();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7C7CC),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Campus Support',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppColors.textTertiary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  ...emergency.map(
                    (r) => _ResourceTile(resource: r, isEmergency: true),
                  ),
                  if (emergency.isNotEmpty) const SizedBox(height: 16),
                  ...others.map((r) => _ResourceTile(resource: r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Single resource tile ---------------------------------------------------

class _ResourceTile extends StatelessWidget {
  final CampusResource resource;
  final bool isEmergency;
  const _ResourceTile({required this.resource, this.isEmergency = false});

  Future<void> _launch() async {
    if (resource.actionUrl != null) {
      final uri = Uri.parse(resource.actionUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resource.actionUrl != null ? _launch : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEmergency
              ? AppColors.danger.withValues(alpha: 0.06)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: isEmergency
              ? Border.all(color: AppColors.danger.withValues(alpha: 0.2))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          resource.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isEmergency
                                ? AppColors.danger
                                : AppColors.text,
                          ),
                        ),
                      ),
                      if (isEmergency) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '24/7',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resource.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (resource.contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resource.contact!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isEmergency
                            ? AppColors.danger
                            : AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (resource.actionUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  _contactIcon(resource.contactType),
                  size: 18,
                  color: isEmergency ? AppColors.danger : AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _contactIcon(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return CupertinoIcons.phone_fill;
      case ContactType.email:
        return CupertinoIcons.mail_solid;
      case ContactType.url:
        return CupertinoIcons.arrow_up_right_square;
      case ContactType.none:
        return CupertinoIcons.chevron_right;
    }
  }
}

// =============================================================================
// Breathing content (stateful pattern selector + BreathingExercise)
// =============================================================================

class _BreathingContent extends StatefulWidget {
  const _BreathingContent();

  @override
  State<_BreathingContent> createState() => _BreathingContentState();
}

class _BreathingContentState extends State<_BreathingContent> {
  static const _patterns = [
    BreathingPattern.boxBreathing,
    BreathingPattern.relaxation478,
    BreathingPattern.physiologicalSigh,
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pattern selector
        SizedBox(
          width: double.infinity,
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _index,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Box', style: TextStyle(fontSize: 13)),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('4-7-8', style: TextStyle(fontSize: 13)),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Sigh', style: TextStyle(fontSize: 13)),
              ),
            },
            onValueChanged: (v) => setState(() => _index = v!),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _patterns[_index].description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        BreathingExercise(pattern: _patterns[_index]),
      ],
    );
  }
}
