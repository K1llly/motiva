import 'dart:convert';
import 'package:flutter/services.dart';

/// Service that loads and provides quote translations based on locale.
/// English is the default language stored in quote data.
/// Other languages are loaded from JSON asset files.
class QuoteTranslationService {
  Map<String, Map<String, String>>? _currentTranslations;
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  /// Load translations for a specific locale.
  /// Call this before the UI rebuilds with the new locale.
  Future<void> loadLocale(String localeCode) async {
    if (localeCode == _currentLocale) return;
    _currentLocale = localeCode;

    if (localeCode == 'en') {
      _currentTranslations = null;
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/quotes_$localeCode.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      _currentTranslations = data.map(
        (key, value) => MapEntry(key, Map<String, String>.from(value as Map)),
      );
    } catch (_) {
      // Translation file not found — fall back to English
      _currentTranslations = null;
    }
  }

  /// Get translated quote text, falls back to original English text.
  String getText(String quoteId, String fallback) {
    return _currentTranslations?[quoteId]?['text'] ?? fallback;
  }

  /// Get translated quote meaning, falls back to original English meaning.
  String getMeaning(String quoteId, String fallback) {
    return _currentTranslations?[quoteId]?['meaning'] ?? fallback;
  }
}
