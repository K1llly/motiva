class NotificationConstants {
  NotificationConstants._();

  // Channel Configuration
  static const String channelId = 'daily_wisdom_channel';
  static const String channelName = 'Daily Wisdom';
  static const String channelDescription = 'Daily stoic quotes to inspire your day';

  // Notification IDs
  static const int dailyQuoteNotificationId = 1;

  // Default Schedule Time (7:00 AM)
  static const int defaultHour = 7;
  static const int defaultMinute = 0;

  // Notification Content
  static const String notificationTitle = 'Motiva';

  // Format the notification body with quote and author
  static String formatBody(String quoteText, String author) {
    return '"$quoteText"\n\n— $author';
  }
}
