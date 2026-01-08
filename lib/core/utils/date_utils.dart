/// Date manipulation helpers for the app
class AppDateUtils {
  AppDateUtils._();

  /// Calculate day number since installation
  static int calculateDayNumber(DateTime installDate) {
    final now = DateTime.now();
    final startOfInstallDay = DateTime(
      installDate.year,
      installDate.month,
      installDate.day,
    );
    final startOfToday = DateTime(now.year, now.month, now.day);

    return startOfToday.difference(startOfInstallDay).inDays + 1;
  }

  /// Get time until next quote (midnight)
  static Duration getTimeUntilNextQuote() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Check if quote should change
  static bool shouldShowNewQuote(DateTime? lastQuoteDate) {
    if (lastQuoteDate == null) return true;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfLastQuote = DateTime(
      lastQuoteDate.year,
      lastQuoteDate.month,
      lastQuoteDate.day,
    );

    return startOfToday.isAfter(startOfLastQuote);
  }

  /// Format duration for display (e.g., "12h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get start of day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
