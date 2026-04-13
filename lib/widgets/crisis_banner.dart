import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

class CrisisBanner extends StatelessWidget {
  final VoidCallback? onTalkToSomeone;
  final VoidCallback? onViewResources;

  const CrisisBanner({
    super.key,
    this.onTalkToSomeone,
    this.onViewResources,
  });

  // Warm palette -- subtle, caring
  static const _warmBg = Color(0xFFFFF8F6);
  static const _warmAccent = Color(0xFFDE6B56);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Wellbeing alert. We noticed your wellbeing has been low. Support is available.',
      liveRegion: true,
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _warmBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          const Icon(
            CupertinoIcons.heart_fill,
            size: 22,
            color: _warmAccent,
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            "We're here for you",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),

          // Message
          const Text(
            'We noticed your wellbeing has been low lately. '
            "You don't have to face this alone.",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.45,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),

          // Primary action
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: onTalkToSomeone,
              color: _warmAccent,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.phone, size: 16, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text(
                    'Talk to someone',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Secondary action
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: onViewResources,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'View resources',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: _warmAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
