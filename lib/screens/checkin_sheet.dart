import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../theme/app_colors.dart';
import '../widgets/mood_picker.dart';

class CheckinSheet extends StatefulWidget {
  /// Fired when the user taps Save. If the callback returns a `Future`, the
  /// sheet awaits it before running the affirmation / pop sequence so that
  /// the dashboard reflects the persisted check-in the moment the sheet
  /// closes.
  final FutureOr<void> Function(int mood, int energy) onComplete;
  final int? initialMood;
  final int? initialEnergy;

  const CheckinSheet({
    super.key,
    required this.onComplete,
    this.initialMood,
    this.initialEnergy,
  });

  /// Shows this sheet as a Cupertino-style modal popup.
  static Future<void> show(
    BuildContext context, {
    required FutureOr<void> Function(int mood, int energy) onComplete,
    int? initialMood,
    int? initialEnergy,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (_) => CheckinSheet(
        onComplete: onComplete,
        initialMood: initialMood,
        initialEnergy: initialEnergy,
      ),
    );
  }

  @override
  State<CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends State<CheckinSheet> {
  late int? _selectedMood;
  late int? _selectedEnergy;
  String? _affirmation;
  bool _showingAffirmation = false;

  static const _energyLabels = [
    'Very low',
    'Low',
    'Moderate',
    'High',
    'Very high',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _selectedEnergy = widget.initialEnergy;
  }

  bool get _canSave => _selectedMood != null && _selectedEnergy != null;

  Future<void> _save() async {
    // Await the save so the dashboard's repo has fired `notifyListeners`
    // before we close this sheet. Previously this was fire-and-forget, which
    // could leave the home screen stuck on the pre-check-in prompt if the
    // affirmation / pop happened to beat the Hive write.
    await widget.onComplete(_selectedMood!, _selectedEnergy!);
    if (!mounted) return;

    final gemini = context.read<AiService>();
    if (gemini.isAvailable) {
      final text =
          await gemini.generateAffirmation(_selectedMood!, _selectedEnergy!);
      if (text != null && mounted) {
        setState(() {
          _affirmation = text;
          _showingAffirmation = true;
        });
        await Future.delayed(const Duration(milliseconds: 2500));
        if (mounted) Navigator.of(context).pop();
        return;
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildAffirmation() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.heart_fill,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _affirmation!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to close',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard iOS drag handle
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
              const SizedBox(height: 24),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Daily Check-in',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Mood picker (emojis are appropriate here)
              MoodPicker(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) =>
                    setState(() => _selectedMood = mood),
              ),
              const SizedBox(height: 32),

              // Energy level header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Energy Level',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Energy level -- simple row of dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = _selectedEnergy == level;
                  final isFilled =
                      _selectedEnergy != null && level <= _selectedEnergy!;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedEnergy = level),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 58,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled
                                  ? AppColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: isFilled
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              letterSpacing: -0.1,
                            ),
                            child: Text(
                              _energyLabels[index],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Affirmation or Save button
              if (_showingAffirmation && _affirmation != null)
                _buildAffirmation()
              else
                SizedBox(
                  width: double.infinity,
                  child: AnimatedOpacity(
                    opacity: _canSave ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: CupertinoButton.filled(
                      onPressed: _canSave ? _save : null,
                      borderRadius: BorderRadius.circular(14),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
