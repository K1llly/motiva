/// Keys for SharedPreferences and Hive storage
class StorageKeys {
  StorageKeys._();

  // Hive box names
  static const String quotesBox = 'quotes';
  static const String streakBox = 'streak';
  static const String userDataBox = 'user_data';

  // SharedPreferences keys
  static const String installDate = 'install_date';
  static const String lastViewedDay = 'last_viewed_day';
  static const String lastQuoteDate = 'last_quote_date';
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationTime = 'notification_time';

  // Quote randomization - unique shuffled order per user
  static const String shuffledQuoteOrder = 'shuffled_quote_order';

  // Language settings
  static const String selectedLanguage = 'selected_language';
}
