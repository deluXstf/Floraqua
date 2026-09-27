import 'package:flutter/material.dart';

import 'floraqua_palette.dart';

export 'floraqua_palette.dart';

/// Радиусы скругления — единые на всё приложение.
class AppRadius {
  AppRadius._();
  static const card = 24.0;
  static const chip = 14.0;
  static const button = 18.0;
}

ThemeData buildAppTheme({required Brightness brightness}) {
  final palette = brightness == Brightness.dark
      ? FloraquaPalette.dark
      : FloraquaPalette.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: brightness == Brightness.dark
        ? const Color(0xFF7DBE82)
        : const Color(0xFF2E7D32),
    brightness: brightness,
    primary: palette.primary,
    onPrimary:
        brightness == Brightness.dark ? const Color(0xFF132316) : Colors.white,
    secondary: palette.secondary,
    error: palette.error,
    surface: palette.surface,
    onSurface: palette.textPrimary,
    outline: palette.divider,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    dividerColor: palette.divider,
    extensions: <ThemeExtension<dynamic>>[palette],
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      hintStyle: TextStyle(color: palette.textSecondary),
      labelStyle: TextStyle(color: palette.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.primary, width: 1.5),
      ),
    ),
    fontFamily: 'Segoe UI',
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: palette.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: palette.textPrimary),
      bodyMedium: TextStyle(color: palette.textPrimary),
      bodySmall: TextStyle(color: palette.textSecondary),
    ),
  );
}
