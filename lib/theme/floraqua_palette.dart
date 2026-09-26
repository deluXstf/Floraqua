import 'package:flutter/material.dart';

/// Семантические цвета Floraqua, привязанные к текущей теме.
@immutable
class FloraquaPalette extends ThemeExtension<FloraquaPalette> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color error;
  final Color warning;
  final Color success;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color shadow;
  final Color chipInactive;
  final Color chipText;
  final Color aiBubble;
  final Color chipEasyBg;
  final Color chipEasyFg;
  final Color chipMediumBg;
  final Color chipMediumFg;
  final Color chipHardBg;
  final Color chipHardFg;

  const FloraquaPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.error,
    required this.warning,
    required this.success,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.shadow,
    required this.chipInactive,
    required this.chipText,
    required this.aiBubble,
    required this.chipEasyBg,
    required this.chipEasyFg,
    required this.chipMediumBg,
    required this.chipMediumFg,
    required this.chipHardBg,
    required this.chipHardFg,
  });

  static const light = FloraquaPalette(
    primary: Color(0xFF2E7D32),
    primaryDark: Color(0xFF1B5E20),
    primaryLight: Color(0xFFDCEEDD),
    secondary: Color(0xFF3B82C4),
    accent: Color(0xFFF0B429),
    background: Color(0xFFF7F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F3EF),
    error: Color(0xFFE15B5B),
    warning: Color(0xFFE8A33D),
    success: Color(0xFF4CAF50),
    textPrimary: Color(0xFF2B2E2C),
    textSecondary: Color(0xFF737A74),
    divider: Color(0xFFE2E7E1),
    shadow: Color(0xFF879187),
    chipInactive: Color(0xFFF0F1EE),
    chipText: Color(0xFF5B5F5B),
    aiBubble: Color(0xFFF1F8F1),
    chipEasyBg: Color(0xFFDFF3E1),
    chipEasyFg: Color(0xFF276B32),
    chipMediumBg: Color(0xFFFBEBD3),
    chipMediumFg: Color(0xFF9A5B12),
    chipHardBg: Color(0xFFFADBDB),
    chipHardFg: Color(0xFFA23A3A),
  );

  static const dark = FloraquaPalette(
    primary: Color(0xFF8BCB8F),
    primaryDark: Color(0xFFB5E1B7),
    primaryLight: Color(0xFF294A31),
    secondary: Color(0xFF82B8E8),
    accent: Color(0xFFFFD166),
    background: Color(0xFF101714),
    surface: Color(0xFF19221D),
    surfaceVariant: Color(0xFF222E27),
    error: Color(0xFFFF8A80),
    warning: Color(0xFFFFCC80),
    success: Color(0xFF9BD49F),
    textPrimary: Color(0xFFE8F0E9),
    textSecondary: Color(0xFFADB9AF),
    divider: Color(0xFF35443A),
    shadow: Color(0xFF000000),
    chipInactive: Color(0xFF27332B),
    chipText: Color(0xFFC8D2C9),
    aiBubble: Color(0xFF213329),
    chipEasyBg: Color(0xFF24452A),
    chipEasyFg: Color(0xFFC3E6C5),
    chipMediumBg: Color(0xFF4A3922),
    chipMediumFg: Color(0xFFFFDCA7),
    chipHardBg: Color(0xFF4A2929),
    chipHardFg: Color(0xFFFFC2BD),
  );

  (Color bg, Color fg) difficultyColors(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'легко':
        return (chipEasyBg, chipEasyFg);
      case 'сложно':
        return (chipHardBg, chipHardFg);
      case 'средне':
      default:
        return (chipMediumBg, chipMediumFg);
    }
  }

  Color wateringStatusColor(int daysUntilWatering) {
    if (daysUntilWatering <= 0) return error;
    if (daysUntilWatering <= 2) return warning;
    return success;
  }

  @override
  FloraquaPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? error,
    Color? warning,
    Color? success,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? shadow,
    Color? chipInactive,
    Color? chipText,
    Color? aiBubble,
    Color? chipEasyBg,
    Color? chipEasyFg,
    Color? chipMediumBg,
    Color? chipMediumFg,
    Color? chipHardBg,
    Color? chipHardFg,
  }) => FloraquaPalette(
        primary: primary ?? this.primary,
        primaryDark: primaryDark ?? this.primaryDark,
        primaryLight: primaryLight ?? this.primaryLight,
        secondary: secondary ?? this.secondary,
        accent: accent ?? this.accent,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        error: error ?? this.error,
        warning: warning ?? this.warning,
        success: success ?? this.success,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        divider: divider ?? this.divider,
        shadow: shadow ?? this.shadow,
        chipInactive: chipInactive ?? this.chipInactive,
        chipText: chipText ?? this.chipText,
        aiBubble: aiBubble ?? this.aiBubble,
        chipEasyBg: chipEasyBg ?? this.chipEasyBg,
        chipEasyFg: chipEasyFg ?? this.chipEasyFg,
        chipMediumBg: chipMediumBg ?? this.chipMediumBg,
        chipMediumFg: chipMediumFg ?? this.chipMediumFg,
        chipHardBg: chipHardBg ?? this.chipHardBg,
        chipHardFg: chipHardFg ?? this.chipHardFg,
      );

  @override
  FloraquaPalette lerp(ThemeExtension<FloraquaPalette>? other, double t) {
    if (other is! FloraquaPalette) return this;
    return FloraquaPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      chipInactive: Color.lerp(chipInactive, other.chipInactive, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      aiBubble: Color.lerp(aiBubble, other.aiBubble, t)!,
      chipEasyBg: Color.lerp(chipEasyBg, other.chipEasyBg, t)!,
      chipEasyFg: Color.lerp(chipEasyFg, other.chipEasyFg, t)!,
      chipMediumBg: Color.lerp(chipMediumBg, other.chipMediumBg, t)!,
      chipMediumFg: Color.lerp(chipMediumFg, other.chipMediumFg, t)!,
      chipHardBg: Color.lerp(chipHardBg, other.chipHardBg, t)!,
      chipHardFg: Color.lerp(chipHardFg, other.chipHardFg, t)!,
    );
  }
}

extension FloraquaThemeContext on BuildContext {
  FloraquaPalette get floraqua =>
      Theme.of(this).extension<FloraquaPalette>() ?? FloraquaPalette.light;
}
