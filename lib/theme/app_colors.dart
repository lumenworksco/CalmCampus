import 'dart:ui';

class AppColors {
  // -- Primary wellness accent (dark sage) --
  static const primary = Color(0xFF7B9460);

  // -- Palette secondaries --
  static const sageMid   = Color(0xFF8DAA72); // mid sage
  static const sageLight = Color(0xFFC2D19E); // light sage
  static const cream     = Color(0xFFF0F4E2); // cream background

  // -- Interactive accent (iOS blue) --
  static const accent = Color(0xFF007AFF);

  // -- Semantic --
  static const danger = Color(0xFFFF3B30);
  static const warning = Color(0xFFFF9F0A);

  // -- Light surfaces --
  static const background = Color(0xFFF2F2F7); // iOS system gray 6
  static const surface = Color(0xFFFFFFFF);

  // -- Dark surfaces --
  static const backgroundDark = Color(0xFF000000);
  static const surfaceDark = Color(0xFF1C1C1E);

  // -- Text hierarchy (light mode, black at varying opacity) --
  static const text = Color(0xD9000000); // 85%
  static const textSecondary = Color(0x99000000); // 60%
  static const textTertiary = Color(0x4D000000); // 30%

  // -- Text hierarchy (dark mode, white at varying opacity) --
  static const textDark = Color(0xD9FFFFFF); // 85%
  static const textSecondaryDark = Color(0x99FFFFFF); // 60%
  static const textTertiaryDark = Color(0x4DFFFFFF); // 30%

  // -- Separators & borders --
  static const separator = Color(0x4A3C3C43); // iOS system separator
  static const border = Color(0xFFE5E5EA);
  static const separatorDark = Color(0x99545458);
  static const borderDark = Color(0xFF38383A);

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
