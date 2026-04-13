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

    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header --
          Padding(
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 4),
            child: const Text(
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Evidence-based wellbeing tools',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),

          // -- Emergency help -- subtle text link --
          if (hasEmergency)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _showEmergencySheet,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.phone_fill,
                        size: 15, color: AppColors.danger),
                    SizedBox(width: 6),
                    Text(
                      'I Need Help Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // -- Breathing --
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sliding segmented control (iOS 13+ style)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _selectedPatternIndex,
                    onValueChanged: (i) {
                      if (i != null) setState(() => _selectedPatternIndex = i);
                    },
                    children: {
                      for (int i = 0; i < _patterns.length; i++)
                        i: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Text(
                            _patterns[i].name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _patterns[_selectedPatternIndex].description,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textTertiary),
                  textAlign: TextAlign.center,
                ),
                Center(
                    child: BreathingExercise(
                        pattern: _patterns[_selectedPatternIndex])),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -- Mindfulness --
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

          const SizedBox(height: 16),

          // -- Gratitude --
          _card(
            child: GratitudeJournal(
              existingEntry: repo.getTodayGratitude(),
              onSave: (entry) => repo.saveGratitude(entry),
            ),
          ),

          const SizedBox(height: 16),

          // -- Relaxation --
          _card(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progressive Muscle Relaxation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                PMRGuide(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -- Quick Actions --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _actionCard(
                  icon: CupertinoIcons.wind,
                  title: 'Take a Walk',
                  desc: '10 min reset',
                  onTap: _showWalkTimer,
                ),
                const SizedBox(width: 8),
                _actionCard(
                  icon: CupertinoIcons.chat_bubble_2,
                  title: 'Reach Out',
                  desc: 'Message a friend',
                  onTap: _openSms,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -- Campus Resources --
          _sectionHeader('CAMPUS RESOURCES'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < nonEmergencyResources.length; i++) ...[
                  _resourceRow(nonEmergencyResources[i]),
                  if (i < nonEmergencyResources.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
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
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable builders
  // ---------------------------------------------------------------------------

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: AppColors.accent),
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
                      fontSize: 17,
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
// Walk Timer
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
                fontSize: 15,
                color: AppColors.textSecondary,
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
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
