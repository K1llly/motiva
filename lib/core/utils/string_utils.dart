/// String formatting helpers
class StringUtils {
  StringUtils._();

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (maxLength <= 0) return '';
    if (text.length <= maxLength) return text;
    if (maxLength <= 3) return text.substring(0, maxLength);
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Format quote for sharing
  static String formatQuoteForSharing(String quote, String author) {
    return '"$quote"\n\n- $author\n\nvia StoicMind';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
