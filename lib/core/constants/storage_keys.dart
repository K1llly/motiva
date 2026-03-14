/// Keys for SharedPreferences and Hive storage
class StorageKeys {
  StorageKeys._();

  // Hive box names
  static const String quotesBox = 'quotes';
  static const String userDataBox = 'user_data';

  // SharedPreferences keys
  static const String installDate = 'install_date';
  static const String lastViewedDay = 'last_viewed_day';
  static const String lastQuoteDate = 'last_quote_date';
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationTime = 'notification_time';

  // Quote randomization - unique shuffled order per user (legacy, kept for cleanup)
  static const String shuffledQuoteOrder = 'shuffled_quote_order';

  // User seed for daily random quote selection
  static const String userSeed = 'user_seed';

  // Quotes data version tracking
  static const String quotesVersion = 'quotes_version';

  // Language settings
  static const String selectedLanguage = 'selected_language';

  // Onboarding
  static const String onboardingCompleted = 'onboarding_completed';

  // Favorites
  static const String favorites = 'favorites';

  // Font
  static const String appFont = 'app_font';
}
