import 'package:flutter/material.dart';
import '../../../../core/theme/app_font.dart';
import '../../../../core/theme/app_typography.dart';

/// A beautiful card designed for sharing on social media.
/// Rendered at 360x360 logical pixels, captured at 3x = 1080x1080 for Instagram.
class ShareCard extends StatelessWidget {
  final String quoteText;
  final String author;
  final Color backgroundColor;
  final Color primaryColor;
  final Color accentColor;
  final AppFont font;

  const ShareCard({
    super.key,
    required this.quoteText,
    required this.author,
    required this.backgroundColor,
    required this.primaryColor,
    required this.accentColor,
    required this.font,
  });

  double _quoteFontSize() {
    final len = quoteText.length;
    if (len < 60) return 22;
    if (len < 100) return 20;
    if (len < 150) return 18;
    if (len < 200) return 16;
    return 14;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.format_quote,
              size: 32,
              color: accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              quoteText,
              style: AppTypography.quoteStyleFor(font).copyWith(
                color: primaryColor,
                fontSize: _quoteFontSize(),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 24, height: 1.5, color: accentColor),
                const SizedBox(width: 10),
                Text(
                  author,
                  style: AppTypography.authorStyleFor(font).copyWith(
                    color: accentColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 24, height: 1.5, color: accentColor),
              ],
            ),
            const Spacer(),
            Text(
              'Motiva',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
