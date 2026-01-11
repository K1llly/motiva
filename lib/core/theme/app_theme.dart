import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Theme configuration for the app
class AppTheme {
  AppTheme._();

  // Cached card border radius
  static final _cardBorderRadius = BorderRadius.circular(16);
  static final _buttonBorderRadius = BorderRadius.circular(12);

  /// Light theme - cached
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 0, // Reduced to save GPU memory
      shape: RoundedRectangleBorder(
        borderRadius: _cardBorderRadius,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: _buttonBorderRadius,
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.primary,
    ),
  );

  /// Dark theme - cached
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.primaryDark,
      onSecondary: AppColors.primaryDark,
      onSurface: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0, // Reduced to save GPU memory
      shape: RoundedRectangleBorder(
        borderRadius: _cardBorderRadius,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: _buttonBorderRadius,
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.secondary,
    ),
  );

  static ThemeData get lightTheme => _lightTheme;
  static ThemeData get darkTheme => _darkTheme;
}
