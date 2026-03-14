import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<Locale?> getSelectedLocale() async {
    final languageCode = _prefs.getString(StorageKeys.selectedLanguage);
    if (languageCode == null) return null;
    return Locale(languageCode);
  }

  @override
  Future<void> saveSelectedLocale(Locale locale) async {
    await _prefs.setString(StorageKeys.selectedLanguage, locale.languageCode);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final value = _prefs.getString(StorageKeys.themeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  @override
  Future<String> getAppFont() async {
    return _prefs.getString(StorageKeys.appFont) ?? 'classic';
  }

  @override
  Future<void> saveAppFont(String fontKey) async {
    await _prefs.setString(StorageKeys.appFont, fontKey);
  }
}
