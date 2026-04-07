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

  // Warm, empathetic palette — soft coral/peach, not alarming red
  static const _warmBg = Color(0xFFFFF0EB);
  static const _warmAccent = Color(0xFFE8725C);
  static const _warmAccentLight = Color(0xFFFADDD6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _warmBg,
            Color(0xFFFFF6F2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _warmAccent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _warmAccentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              '\u{1F932}', // cupped hands emoji
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            "We're here for you",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),

          // Message
          const Text(
            "We noticed your wellbeing has been low. You don't have to face this alone.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Buttons — stacked vertically
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onTalkToSomeone,
              style: TextButton.styleFrom(
                backgroundColor: _warmAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Talk to someone'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewResources,
              style: OutlinedButton.styleFrom(
                foregroundColor: _warmAccent,
                side: const BorderSide(color: _warmAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('View resources'),
            ),
          ),
        ],
      ),
    );
  }
}
