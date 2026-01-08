import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../quote/domain/entities/quote.dart';

class ShareBottomSheet extends StatelessWidget {
  final Quote quote;

  const ShareBottomSheet({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Quote',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () => _shareToInstagram(context),
              ),
              _ShareOption(
                icon: Icons.alternate_email,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () => _shareToTwitter(context),
              ),
              _ShareOption(
                icon: Icons.chat_bubble,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToWhatsApp(context),
              ),
              _ShareOption(
                icon: Icons.more_horiz,
                label: 'More',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () => _shareGeneric(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SafeArea(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  String _getShareText() {
    return StringUtils.formatQuoteForSharing(quote.text, quote.author);
  }

  void _shareToInstagram(BuildContext context) {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Stoic Quote');
    Navigator.pop(context);
  }

  void _shareToTwitter(BuildContext context) {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Stoic Quote');
    Navigator.pop(context);
  }

  void _shareToWhatsApp(BuildContext context) {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Stoic Quote');
    Navigator.pop(context);
  }

  void _shareGeneric(BuildContext context) {
    final text = _getShareText();
    Share.share(text, subject: 'Daily Stoic Quote');
    Navigator.pop(context);
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
