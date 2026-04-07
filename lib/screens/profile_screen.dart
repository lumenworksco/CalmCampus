import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Privacy
          _sectionLabel('PRIVACY'),
          _groupedCard([
            _row('Data processing', 'On-device only'),
            _row('Cloud storage', 'None'),
            _row('GDPR compliant', 'Yes', isLast: true),
          ]),
          _footer('All behavioral data is processed locally on your device. No personal data ever leaves your phone.'),

          // Notifications
          _sectionLabel('NOTIFICATIONS'),
          _groupedCard([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wellness nudges', style: TextStyle(fontSize: 15, color: AppColors.text)),
                        const SizedBox(height: 2),
                        const Text('Gentle alerts when stress is detected', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

          // Technology
          _sectionLabel('TECHNOLOGY'),
          _groupedCard([
            _row('Processing', 'On-device only'),
            _row('Data collection', 'Passive sensing'),
            _row('Interventions', 'CBT & ACT based'),
            _row('Privacy', 'GDPR-native', isLast: true),
          ]),

          // About
          _sectionLabel('ABOUT'),
          _groupedCard([
            _row('Version', '1.0.0'),
            _row('Framework', 'CBT & ACT', isLast: true),
          ]),
          _footer('CalmCampus detects early signs of student burnout via behavioral signals and delivers personalized micro-interventions.'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
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

  Widget _row(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 15, color: AppColors.text)),
              Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
          ),
      ],
    );
  }

  Widget _footer(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}
