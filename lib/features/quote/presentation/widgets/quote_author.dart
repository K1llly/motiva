import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class QuoteAuthor extends StatelessWidget {
  final String author;

  const QuoteAuthor({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    // Cache theme reference once to avoid repeated lookups
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final lineColor = secondaryColor.withValues(alpha: 0.5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 1,
          color: lineColor,
        ),
        const SizedBox(width: 12),
        Text(
          author,
          style: AppTypography.authorStyle(context).copyWith(
            color: secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 30,
          height: 1,
          color: lineColor,
        ),
      ],
    );
  }
}
