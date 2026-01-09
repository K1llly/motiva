import 'dart:ui';
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
}
