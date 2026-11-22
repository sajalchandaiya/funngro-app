import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerHighest: AppColors.card,
      primaryContainer: AppColors.muted,
      onPrimaryContainer: AppColors.accent,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
    ),
    dividerColor: AppColors.border,
  );
}
