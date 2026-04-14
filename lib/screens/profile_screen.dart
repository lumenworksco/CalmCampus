import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../services/wellness_repository.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final repo = context.watch<WellnessRepository>();
    final ai = context.watch<AiService>();
    final topPadding = MediaQuery.of(context).padding.top;

    return CupertinoScrollbar(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Large title header --
            Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 0),
              child: const Text(
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
                            'Gentle alerts when stress is detected (coming soon)',
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
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) => appState.setNotificationsEnabled(v),
                    ),
                  ],
                ),
              ),
            ]),

            // -- AI section --
            _sectionLabel('AI'),
            _groupedCard([
              _infoRow(
                'Status',
                !ai.isInitialized
                    ? 'Loading...'
                    : !ai.hasKey
                        ? 'No API key'
                        : ai.lastError != null
                            ? 'Error'
                            : 'Ready',
              ),
              _separator(),
              _tappableRow(
                label: 'API Key',
                trailing: ai.maskedKey,
                onTap: () => _editApiKey(context, ai),
              ),
              _separator(),
              _tappableRow(
                label: 'Model',
                trailing: ai.model,
                onTap: () => _editModel(context, ai),
              ),
              _separator(),
              _tappableRow(
                label: 'Test connection',
                onTap: () => _testAi(context, ai),
                isLast: true,
              ),
            ]),
            _footer(
              'AI features use Groq, a free cloud API (14,400 req/day). '
              'Sign up at console.groq.com, paste your API key above. Your '
              'key is stored only on this device.',
            ),

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
              _infoRow('Version', _version.isEmpty ? '...' : _version),
              _separator(),
              _infoRow('Framework', 'CBT & ACT'),
              _separator(),
              _infoRow('KICK Challenge 2026', ''),
            ]),
            _footer(
              'Calm Campus detects early signs of student burnout via '
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
  // Dialogs
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

  Future<void> _editApiKey(BuildContext context, AiService ai) async {
    final controller = TextEditingController();
    final newKey = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Groq API Key'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: controller,
                autofocus: true,
                placeholder: 'gsk_...',
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Get a free key at console.groq.com',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (ai.hasKey)
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Remove'),
            ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newKey != null) {
      await ai.setApiKey(newKey);
    }
  }

  Future<void> _editModel(BuildContext context, AiService ai) async {
    final controller = TextEditingController(text: ai.model);
    final newModel = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Model'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: controller,
                autofocus: true,
                placeholder: 'llama-3.3-70b-versatile',
                autocorrect: false,
              ),
              const SizedBox(height: 8),
              const Text(
                'e.g. llama-3.3-70b-versatile, llama-3.1-8b-instant',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
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
    if (newModel != null && newModel.trim().isNotEmpty) {
      await ai.setModel(newModel);
    }
  }

  Future<void> _testAi(BuildContext context, AiService ai) async {
    final ok = await ai.ping();
    if (!context.mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(ok ? 'Connected' : 'Failed'),
        content: Text(
          ok
              ? 'AI is reachable and your key works. Ready to generate '
                  'insights and suggestions.'
              : ai.lastError ??
                  'Could not reach Groq. Check your API key and internet '
                      'connection.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
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
  // Building blocks -- iOS Settings style
  // ---------------------------------------------------------------------------

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 35, 16, 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _separator() {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(
        height: 0.33,
        thickness: 0.33,
        color: AppColors.separator,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    String? trailing,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            if (trailing != null) ...[
              Flexible(
                child: Text(
                  trailing,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
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

  Widget _footer(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
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
