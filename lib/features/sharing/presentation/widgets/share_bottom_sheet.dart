import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quote/domain/entities/quote.dart';

class ShareBottomSheet extends StatelessWidget {
  final Quote quote;

  const ShareBottomSheet({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Cache theme references once
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurface.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.shareQuote,
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.camera_alt,
                label: l10n.instagram,
                color: const Color(0xFFE4405F),
                labelStyle: theme.textTheme.bodySmall,
                onTap: () => _shareToInstagram(context, l10n),
              ),
              _ShareOption(
                icon: Icons.alternate_email,
                label: l10n.twitter,
                color: const Color(0xFF1DA1F2),
                labelStyle: theme.textTheme.bodySmall,
                onTap: () => _shareToTwitter(context, l10n),
              ),
              _ShareOption(
                icon: Icons.chat_bubble,
                label: l10n.whatsapp,
                color: const Color(0xFF25D366),
                labelStyle: theme.textTheme.bodySmall,
                onTap: () => _shareToWhatsApp(context, l10n),
              ),
              _ShareOption(
                icon: Icons.more_horiz,
                label: l10n.more,
                color: colorScheme.secondary,
                labelStyle: theme.textTheme.bodySmall,
                onTap: () => _shareGeneric(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SafeArea(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }

  String _getShareText() {
    return StringUtils.formatQuoteForSharing(quote.text, quote.author);
  }

  void _shareToInstagram(BuildContext context, AppLocalizations l10n) {
    final text = _getShareText();
    Share.share(text, subject: l10n.dailyStoicQuote);
    Navigator.pop(context);
  }

  void _shareToTwitter(BuildContext context, AppLocalizations l10n) {
    final text = _getShareText();
    Share.share(text, subject: l10n.dailyStoicQuote);
    Navigator.pop(context);
  }

  void _shareToWhatsApp(BuildContext context, AppLocalizations l10n) {
    final text = _getShareText();
    Share.share(text, subject: l10n.dailyStoicQuote);
    Navigator.pop(context);
  }

  void _shareGeneric(BuildContext context, AppLocalizations l10n) {
    final text = _getShareText();
    Share.share(text, subject: l10n.dailyStoicQuote);
    Navigator.pop(context);
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-compute background color once
    final backgroundColor = color.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
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
            style: labelStyle,
          ),
        ],
      ),
    );
  }
}
