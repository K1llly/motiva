import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font.dart';
import 'app_typography.dart';

/// Theme configuration for the app
class AppTheme {
  AppTheme._();

  static const _cardBorderRadius = BorderRadius.all(Radius.circular(16));
  static const _buttonBorderRadius = BorderRadius.all(Radius.circular(12));

  static final Map<AppFont, ThemeData> _lightCache = {};
  static final Map<AppFont, ThemeData> _darkCache = {};

  static ThemeData lightThemeFor(AppFont font) {
    return _lightCache.putIfAbsent(font, () => _buildLight(font));
  }

  static ThemeData darkThemeFor(AppFont font) {
    return _darkCache.putIfAbsent(font, () => _buildDark(font));
  }

  /// Default themes (classic font)
  static ThemeData get lightTheme => lightThemeFor(AppFont.classic);
  static ThemeData get darkTheme => darkThemeFor(AppFont.classic);

  static ThemeData _buildLight(AppFont font) {
    return ThemeData(
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
      textTheme: AppTypography.textThemeFor(font).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: _buttonBorderRadius),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
    );
  }

  static ThemeData _buildDark(AppFont font) {
    return ThemeData(
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
      textTheme: AppTypography.textThemeFor(font).apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _cardBorderRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: _buttonBorderRadius),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.secondary),
    );
  }
}
