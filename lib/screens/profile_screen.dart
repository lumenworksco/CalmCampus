import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final repo = context.watch<WellnessRepository>();

    return CupertinoScrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Large title header --
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            // -- Privacy section --
            _sectionLabel('PRIVACY'),
            _groupedCard([
              _infoRow('Data processing', 'On-device only'),
              _separator(),
              _infoRow('Cloud storage', 'None'),
              _separator(),
              _infoRow('GDPR compliant', 'Yes'),
            ]),
            _footer(
              'All behavioral data is processed locally on your device. '
              'No personal data ever leaves your phone.',
            ),

            // -- Notifications section --
            _sectionLabel('NOTIFICATIONS'),
            _groupedCard([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wellness nudges',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gentle alerts when stress is detected',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: appState.notificationsEnabled,
                      activeTrackColor: AppColors.success,
                      onChanged: (v) => appState.setNotificationsEnabled(v),
                    ),
                  ],
                ),
              ),
            ]),

            // -- Data Management section --
            _sectionLabel('DATA MANAGEMENT'),
            _groupedCard([
              _tappableRow(
                label: 'Reset Onboarding',
                onTap: () => _confirmResetOnboarding(context, appState),
                isFirst: true,
              ),
              _separator(),
              _tappableRow(
                label: 'Clear All Data',
                onTap: () => _confirmClearData(context, repo),
                isDestructive: true,
                isLast: true,
              ),
            ]),
            _footer(
              'Resetting onboarding will show the welcome screens again. '
              'Clearing data removes all wellness entries.',
            ),

            // -- About section --
            _sectionLabel('ABOUT'),
            _groupedCard([
              _infoRow('Version', '1.0.0'),
              _separator(),
              _infoRow('Framework', 'CBT & ACT'),
              _separator(),
              _infoRow('KICK Challenge 2026', ''),
            ]),
            _footer(
              'CalmCampus detects early signs of student burnout via '
              'behavioral signals and delivers personalized '
              'micro-interventions. Built for the KU Leuven KICK Challenge.',
            ),

            // -- Bottom padding for tab bar --
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs -- Cupertino style
  // ---------------------------------------------------------------------------

  void _confirmResetOnboarding(BuildContext context, AppState appState) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset Onboarding'),
        content: const Text(
          'This will show the welcome screens again on next launch.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              appState.setHasOnboarded(false);
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WellnessRepository repo) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your wellness data. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              repo.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable building blocks
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _groupedCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: AppColors.border,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 17, color: AppColors.text),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tappableRow({
    required String label,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  color: isDestructive
                      ? CupertinoColors.destructiveRed
                      : AppColors.text,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: AppColors.textTertiary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
