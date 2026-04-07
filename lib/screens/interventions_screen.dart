import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/interventions_data.dart';
import '../models/breathing_pattern.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/breathing_exercise.dart';
import '../widgets/gratitude_journal.dart';
import '../widgets/pmr_guide.dart';

class InterventionsScreen extends StatefulWidget {
  const InterventionsScreen({super.key});

  @override
  State<InterventionsScreen> createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  int _promptIndex = 0;
  int _selectedPatternIndex = 0;

  static const _patterns = [
    BreathingPattern.boxBreathing,
    BreathingPattern.relaxation478,
    BreathingPattern.physiologicalSigh,
  ];

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _launchContact(CampusResource resource) async {
    if (resource.actionUrl != null) {
      final uri = Uri.parse(resource.actionUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _showEmergencySheet() {
    final emergencyResources =
        campusResources.where((r) => r.isEmergency).toList();

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Emergency Resources'),
        message: const Text('Immediate help is available'),
        actions: [
          for (final resource in emergencyResources)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _launchContact(resource);
              },
              isDestructiveAction: true,
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
                        fontWeight: FontWeight.w700,
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

  void _showWalkTimer() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => const _WalkTimerDialog(),
    );
  }

  Future<void> _openSms() async {
    final uri = Uri.parse('sms:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WellnessRepository>();
    final hasEmergency = campusResources.any((r) => r.isEmergency);
    final nonEmergencyResources =
        campusResources.where((r) => !r.isEmergency).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header --
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 4),
            child: Text(
              'Calm',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Evidence-based wellbeing tools',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),

          // -- Emergency button --
          if (hasEmergency)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.zero,
                  onPressed: _showEmergencySheet,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.phone_fill,
                          size: 18, color: CupertinoColors.white),
                      SizedBox(width: 8),
                      Text(
                        'I Need Help Now',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // -- Breathing --
          _sectionHeader('BREATHING'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Segmented control for pattern
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSegmentedControl<int>(
                    groupValue: _selectedPatternIndex,
                    onValueChanged: (i) =>
                        setState(() => _selectedPatternIndex = i),
                    padding: EdgeInsets.zero,
                    children: {
                      for (int i = 0; i < _patterns.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          child: Text(
                            _patterns[i].name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    },
                  ),
                ),
                BreathingExercise(pattern: _patterns[_selectedPatternIndex]),
              ],
            ),
          ),

          // -- Mindfulness --
          _sectionHeader('MINDFULNESS'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mindfulnessPrompts[_promptIndex],
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.text,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                    minimumSize: const Size(44, 44),
                    onPressed: () => setState(() => _promptIndex =
                        (_promptIndex + 1) % mindfulnessPrompts.length),
                    child: const Text(
                      'Next Prompt',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -- Gratitude --
          _sectionHeader('GRATITUDE'),
          _card(
            child: GratitudeJournal(
              existingEntry: repo.getTodayGratitude(),
              onSave: (entry) => repo.saveGratitude(entry),
            ),
          ),

          // -- Relaxation --
          _sectionHeader('RELAXATION'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progressive Muscle Relaxation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const PMRGuide(),
              ],
            ),
          ),

          // -- Quick Actions --
          _sectionHeader('QUICK ACTIONS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _actionCard(
                  icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                  title: 'Take a Walk',
                  desc: '10 min reset',
                  onTap: _showWalkTimer,
                ),
                const SizedBox(width: 12),
                _actionCard(
                  icon: CupertinoIcons.chat_bubble_2,
                  title: 'Reach Out',
                  desc: 'Message a friend',
                  onTap: _openSms,
                ),
              ],
            ),
          ),

          // -- Campus Resources --
          _sectionHeader('CAMPUS RESOURCES'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
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
                for (int i = 0; i < nonEmergencyResources.length; i++) ...[
                  _resourceRow(nonEmergencyResources[i]),
                  if (i < nonEmergencyResources.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.border),
                    ),
                ],
              ],
            ),
          ),

          // Bottom padding for tab bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable builders
  // ---------------------------------------------------------------------------

  /// iOS Settings-style uppercase gray section header.
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// White card with subtle shadow and rounded corners.
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Side-by-side quick-action card (takes a Cupertino icon rather than emoji).
  Widget _actionCard({
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
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
              Icon(icon, size: 28, color: AppColors.accent),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// iOS grouped-list style resource row with chevron.
  Widget _resourceRow(CampusResource resource) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _launchContact(resource),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resource.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (resource.contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resource.contact!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                resource.type,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Walk Timer — CupertinoAlertDialog
// =============================================================================

class _WalkTimerDialog extends StatefulWidget {
  const _WalkTimerDialog();

  @override
  State<_WalkTimerDialog> createState() => _WalkTimerDialogState();
}

class _WalkTimerDialogState extends State<_WalkTimerDialog> {
  static const _totalSeconds = 10 * 60;
  int _remaining = _totalSeconds;
  Timer? _timer;
  bool _started = false;

  void _startTimer() {
    setState(() => _started = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Take a Walk'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your body and mind will thank you',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (!_started) ...[
              const SizedBox(height: 16),
              CupertinoButton(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                minimumSize: const Size(44, 44),
                onPressed: _startTimer,
                child: const Text(
                  'Start Timer',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ] else if (_remaining == 0) ...[
              const SizedBox(height: 16),
              const Text(
                'Well done!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
