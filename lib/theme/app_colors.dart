import 'dart:ui';

class AppColors {
  // -- Primary wellness accent (green) --
  static const primary = Color(0xFF34C759);

  // -- Interactive accent (iOS blue) --
  static const accent = Color(0xFF007AFF);

  // -- Semantic --
  static const danger = Color(0xFFFF3B30);
  static const warning = Color(0xFFFF9F0A);

  // -- Surfaces --
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);

  // -- Text hierarchy (black at varying opacity) --
  static const text = Color(0xD9000000); // 85%
  static const textSecondary = Color(0x99000000); // 60%
  static const textTertiary = Color(0x4D000000); // 30%

  // -- Separators & borders --
  static const separator = Color(0x4A3C3C43); // iOS system separator
  static const border = Color(0xFFE5E5EA);

  // ---------------------------------------------------------------------------
  // Wellness helpers
  // ---------------------------------------------------------------------------

  static Color getWellnessColor(int score) {
    if (score >= 65) return primary;
    if (score >= 40) return warning;
    return danger;
  }

  static String getWellnessLabel(int score) {
    if (score >= 80) return "You're doing great";
    if (score >= 65) return 'Mostly good, stay mindful';
    if (score >= 50) return 'We noticed some changes';
    if (score >= 35) return 'Consider taking a break';
    return "Let's focus on your wellbeing";
  }
}
