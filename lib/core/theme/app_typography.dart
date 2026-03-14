import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stoic_mind/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:stoic_mind/features/settings/presentation/bloc/settings_state.dart';
import 'app_font.dart';

/// Text styles for the app, dynamically generated based on font choice
class AppTypography {
  AppTypography._();

  static final Map<AppFont, TextTheme> _textThemeCache = {};
  static final Map<AppFont, TextStyle> _quoteStyleCache = {};
  static final Map<AppFont, TextStyle> _authorStyleCache = {};

  static TextTheme textThemeFor(AppFont font) {
    return _textThemeCache.putIfAbsent(font, () => _buildTextTheme(font));
  }

  /// Default text theme (classic font)
  static TextTheme get textTheme => textThemeFor(AppFont.classic);

  static TextTheme _buildTextTheme(AppFont font) {
    final primary = font.primaryStyle;
    final body = font.bodyStyle;

    return TextTheme(
      displayLarge: primary.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: primary.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: primary.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: body.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: body.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: body.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: body.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: body.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: body.copyWith(fontSize: 10, fontWeight: FontWeight.w500),
    );
  }

  /// Quote text style
  static TextStyle quoteStyleFor(AppFont font) {
    return _quoteStyleCache.putIfAbsent(
      font,
      () => font.primaryStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  /// Author text style
  static TextStyle authorStyleFor(AppFont font) {
    return _authorStyleCache.putIfAbsent(
      font,
      () => font.bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.2,
      ),
    );
  }

  /// Context-aware accessors that read the current app font from SettingsBloc
  static TextStyle quoteStyle(BuildContext context) {
    final font = _fontFromContext(context);
    return quoteStyleFor(font);
  }

  static TextStyle authorStyle(BuildContext context) {
    final font = _fontFromContext(context);
    return authorStyleFor(font);
  }

  static AppFont _fontFromContext(BuildContext context) {
    try {
      final state = context.read<SettingsBloc>().state;
      if (state is SettingsLoaded) {
        return AppFont.fromKey(state.appFontKey);
      }
    } catch (_) {}
    return AppFont.classic;
  }
}
