/// Social sharing helpers
class ShareUtils {
  ShareUtils._();

  /// Generate Twitter share URL
  static String getTwitterShareUrl(String text) {
    final encodedText = Uri.encodeComponent(text);
    return 'https://twitter.com/intent/tweet?text=$encodedText';
  }

  /// Generate WhatsApp share URL
  static String getWhatsAppShareUrl(String text) {
    final encodedText = Uri.encodeComponent(text);
    return 'https://wa.me/?text=$encodedText';
  }

  /// Format text for Instagram (plain text, user copies)
  static String formatForInstagram(String quote, String author) {
    return '"$quote"\n\n- $author\n\n#stoic #philosophy #wisdom #dailyquote';
  }
}
