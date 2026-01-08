import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/share_utils.dart';

class ShareService {
  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  Future<void> shareToTwitter(String text) async {
    // Could use ShareUtils.getTwitterShareUrl(text) for URL-based sharing
    await Share.share(text, subject: 'Daily Stoic Quote');
  }

  Future<void> shareToWhatsApp(String text) async {
    // Could use ShareUtils.getWhatsAppShareUrl(text) for URL-based sharing
    await Share.share(text, subject: 'Daily Stoic Quote');
  }

  Future<void> shareForInstagram(String text) async {
    // Instagram doesn't support direct text sharing
    // User copies text and opens Instagram
    await Share.share(text, subject: 'Daily Stoic Quote');
  }
}
