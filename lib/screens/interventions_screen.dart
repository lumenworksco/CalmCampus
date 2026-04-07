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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Resources',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Immediate help is available',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                for (final resource in emergencyResources) ...[
                  InkWell(
                    onTap: () => _launchContact(resource),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  resource.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (resource.contact != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    resource.contact!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.danger,
                            ),
                            child: const Icon(
                              CupertinoIcons.phone_fill,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWalkTimer() {
    showDialog(
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

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<WellnessRepository>();
    final hasEmergency = campusResources.any((r) => r.isEmergency);

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
                  'Calm',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Evidence-based wellbeing tools',
                  style:
                      TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // I Need Help Now button
          if (hasEmergency)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _showEmergencySheet,
                  icon: const Icon(CupertinoIcons.phone_fill, size: 18),
                  label: const Text('I Need Help Now'),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.dangerLight,
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

          // Breathing section
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Breathing Exercises',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                // Chip selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_patterns.length, (i) {
                      final selected = i == _selectedPatternIndex;
                      return Padding(
                        padding: EdgeInsets.only(right: i < _patterns.length - 1 ? 8 : 0),
                        child: ChoiceChip(
                          label: Text(_patterns[i].name),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedPatternIndex = i),
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.text,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                        ),
                      );
                    }),
                  ),
                ),
                BreathingExercise(
                    pattern: _patterns[_selectedPatternIndex]),
              ],
            ),
          ),

          // Mindfulness
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mindfulness',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mindfulnessPrompts[_promptIndex],
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.text,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() =>
                      _promptIndex =
                          (_promptIndex + 1) % mindfulnessPrompts.length),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Next Prompt'),
                ),
              ],
            ),
          ),

          // Gratitude Journal
          _card(
            child: GratitudeJournal(
              existingEntry: repo.getTodayGratitude(),
              onSave: (entry) => repo.saveGratitude(entry),
            ),
          ),

          // Progressive Muscle Relaxation
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

          // Quick Actions
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _actionCard(
                  emoji: '\u{1F6B6}',
                  title: 'Take a Walk',
                  desc: '10 min reset',
                  onTap: _showWalkTimer,
                ),
                const SizedBox(width: 12),
                _actionCard(
                  emoji: '\u{1F4AC}',
                  title: 'Reach Out',
                  desc: 'Message a friend',
                  onTap: _openSms,
                ),
              ],
            ),
          ),

          // Campus Resources
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Text(
              'Campus Resources',
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
                for (int i = 0; i < campusResources.length; i++) ...[
                  _resourceRow(campusResources[i]),
                  if (i < campusResources.length - 1)
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }

  Widget _actionCard({
    required String emoji,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
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
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
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
                  fontSize: 12,
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
    return InkWell(
      onTap: () => _launchContact(resource),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: resource.isEmergency
                          ? AppColors.danger
                          : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    resource.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (resource.contact != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      resource.contact!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: resource.isEmergency
                            ? AppColors.danger
                            : AppColors.accent,
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
                color: resource.isEmergency
                    ? AppColors.dangerLight
                    : AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                resource.type,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: resource.isEmergency
                      ? AppColors.danger
                      : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
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

// -- Walk Timer Dialog --

class _WalkTimerDialog extends StatefulWidget {
  const _WalkTimerDialog();

  @override
  State<_WalkTimerDialog> createState() => _WalkTimerDialogState();
}

class _WalkTimerDialogState extends State<_WalkTimerDialog> {
  static const _totalSeconds = 10 * 60; // 10 minutes
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Take a Walk',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 12),
          const Text(
            'Your body and mind will thank you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (!_started)
            TextButton(
              onPressed: _startTimer,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: const Text('Start Timer'),
            )
          else if (_remaining == 0)
            const Text(
              'Well done!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
