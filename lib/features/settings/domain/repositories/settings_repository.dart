import 'dart:ui';
import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<Locale?> getSelectedLocale();
  Future<void> saveSelectedLocale(Locale locale);
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
  Future<String> getAppFont();
  Future<void> saveAppFont(String fontKey);
}
