import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    // Cache theme references once to avoid repeated lookups
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Card(
      elevation: 0, // Reduced to save GPU memory (IOSurface)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote,
              size: 40,
              color: secondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              quote.text,
              style: AppTypography.quoteStyle(context).copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: secondaryColor,
                ),
                const SizedBox(width: 16),
                Text(
                  quote.author,
                  style: AppTypography.authorStyle(context).copyWith(
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 2,
                  color: secondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
