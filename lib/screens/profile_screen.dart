import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../navigation/tab_padding.dart';
import '../providers/app_state.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final repo = context.watch<WellnessRepository>();
    final topPadding = MediaQuery.of(context).viewPadding.top;

    final streak = repo.getStreak();
    final longestStreak = repo.getLongestStreak();
    final totalCheckins = repo.getTotalCheckins();
    final gratitudeEntries = repo.getTotalGratitudeEntries();
    final daysTracked = repo.getDaysTracked();

    final displayName =
        appState.userName.isEmpty ? 'Student' : appState.userName;
    final memberSince = appState.memberSince ?? DateTime.now();

    return CupertinoScrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Header with settings gear --
            Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding, 14, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openSettings(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        CupertinoIcons.gear,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // -- Avatar + name card --
            _avatarCard(
              context,
              displayName: displayName,
              memberSince: memberSince,
              onEditName: () => _editName(context, appState),
            ),

            // -- Stats --
            _sectionLabel('STATS'),
            _groupedCard([
              _statRow(
                icon: CupertinoIcons.flame_fill,
                iconColor: AppColors.warning,
                label: 'Current streak',
                value: streak == 1 ? '1 day' : '$streak days',
              ),
              _separator(),
              _statRow(
                icon: CupertinoIcons.star_fill,
                iconColor: const Color(0xFFFFD60A),
                label: 'Longest streak',
                value: longestStreak == 1 ? '1 day' : '$longestStreak days',
              ),
              _separator(),
              _statRow(
                icon: CupertinoIcons.checkmark_circle_fill,
                iconColor: AppColors.primary,
                label: 'Total check-ins',
                value: totalCheckins.toString(),
              ),
              _separator(),
              _statRow(
                icon: CupertinoIcons.heart_fill,
                iconColor: const Color(0xFFFF2D55),
                label: 'Gratitude entries',
                value: gratitudeEntries.toString(),
              ),
              _separator(),
              _statRow(
                icon: CupertinoIcons.calendar,
                iconColor: AppColors.accent,
                label: 'Days tracked',
                value: daysTracked.toString(),
              ),
            ]),

            // -- Achievements --
            _sectionLabel('ACHIEVEMENTS'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _achievementsGrid(
                totalCheckins: totalCheckins,
                longestStreak: longestStreak,
                gratitudeEntries: gratitudeEntries,
                currentStreak: streak,
              ),
            ),

            _footer(
              'Achievements are earned by maintaining consistent check-ins '
              'and a healthy wellness score above 70.',
            ),

            // Bottom padding — native iOS tab bar height comes via
            // safe-area; Android adds the floating Flutter tab bar.
            SizedBox(height: tabBarBottomPadding(context)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _editName(BuildContext context, AppState appState) async {
    final controller = TextEditingController(text: appState.userName);
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Your name'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: 'How should we call you?',
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await appState.setUserName(result);
    }
  }

  // ---------------------------------------------------------------------------
  // Building blocks
  // ---------------------------------------------------------------------------

  Widget _avatarCard(
    BuildContext context, {
    required String displayName,
    required DateTime memberSince,
    required VoidCallback onEditName,
  }) {
    final initials = _initialsOf(displayName);
    final since = DateFormat('MMMM yyyy').format(memberSince);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEditName,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Photo avatar with initials fallback if image fails to load
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/avatar.jpg',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        Color(0xFF5AC8FA),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Member since $since',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.pencil,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementsGrid({
    required int totalCheckins,
    required int longestStreak,
    required int gratitudeEntries,
    required int currentStreak,
  }) {
    final achievements = <_Achievement>[
      _Achievement(
        icon: CupertinoIcons.checkmark_seal_fill,
        label: 'First check-in',
        unlocked: totalCheckins >= 1,
        color: AppColors.primary,
      ),
      _Achievement(
        icon: CupertinoIcons.flame_fill,
        label: '3-day streak',
        unlocked: longestStreak >= 3,
        color: AppColors.warning,
      ),
      _Achievement(
        icon: CupertinoIcons.sparkles,
        label: '7-day streak',
        unlocked: longestStreak >= 7,
        color: const Color(0xFFFF9500),
      ),
      _Achievement(
        icon: CupertinoIcons.star_circle_fill,
        label: '10 check-ins',
        unlocked: totalCheckins >= 10,
        color: const Color(0xFFFFD60A),
      ),
      _Achievement(
        icon: CupertinoIcons.rosette,
        label: '30-day streak',
        unlocked: longestStreak >= 30,
        color: const Color(0xFFAF52DE),
      ),
      _Achievement(
        icon: CupertinoIcons.heart_fill,
        label: 'First gratitude',
        unlocked: gratitudeEntries >= 1,
        color: const Color(0xFFFF2D55),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (_, i) => _achievementTile(achievements[i]),
    );
  }

  Widget _achievementTile(_Achievement a) {
    final opacity = a.unlocked ? 1.0 : 0.35;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: a.unlocked
                  ? a.color.withValues(alpha: 0.12)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(19),
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: opacity,
              child: Icon(
                a.icon,
                size: 18,
                color: a.unlocked ? a.color : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            a.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: a.unlocked
                  ? AppColors.text
                  : AppColors.textTertiary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 14, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _groupedCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _separator() {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      color: AppColors.separator,
      indent: 14,
      endIndent: 14,
    );
  }

  Widget _footer(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'S';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Achievement {
  final IconData icon;
  final String label;
  final bool unlocked;
  final Color color;

  const _Achievement({
    required this.icon,
    required this.label,
    required this.unlocked,
    required this.color,
  });
}
