import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class QuoteAuthor extends StatelessWidget {
  final String author;

  const QuoteAuthor({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 1,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
        const SizedBox(width: 12),
        Text(
          author,
          style: AppTypography.authorStyle(context).copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 30,
          height: 1,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ],
    );
  }
}
