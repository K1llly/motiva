import 'dart:ui';

abstract class SettingsRepository {
  Future<Locale?> getSelectedLocale();
  Future<void> saveSelectedLocale(Locale locale);
}
