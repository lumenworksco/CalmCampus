import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CrisisBanner extends StatelessWidget {
  final VoidCallback? onTalkToSomeone; // calls tel:106
  final VoidCallback? onViewResources; // navigates to resources

  const CrisisBanner({
    super.key,
    this.onTalkToSomeone,
    this.onViewResources,
  });

  // Refined warm palette -- soft, caring, not clinical
  static const _warmBg = Color(0xFFFFF5F1);
  static const _warmAccent = Color(0xFFDE6B56);
  static const _warmAccentSoft = Color(0xFFF5D4CB);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _warmBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _warmAccentSoft,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intentional icon -- warm hand, not childish
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _warmAccentSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              CupertinoIcons.heart_fill,
              size: 22,
              color: _warmAccent,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            "We're here for you",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),

          // Message -- caring tone
          const Text(
            "We noticed your wellbeing has been low lately. "
            "You don't have to face this alone.",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.45,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),

          // Primary action -- Cupertino filled button
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
                  Icon(CupertinoIcons.phone, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Talk to someone',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary action -- subtle Cupertino style
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: onViewResources,
              padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }
}
