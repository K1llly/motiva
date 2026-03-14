import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final String displayText;
  final bool showFavoriteButton;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.displayText,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Card(
      elevation: 0,
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
            if (showFavoriteButton)
              Align(
                alignment: Alignment.topRight,
                child: FavoriteButton(quoteId: quote.id),
              ),
            Icon(
              Icons.format_quote,
              size: 40,
              color: secondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              displayText,
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
