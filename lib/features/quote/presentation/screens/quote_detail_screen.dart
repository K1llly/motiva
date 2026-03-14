import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/quote_translation_service.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/quote.dart';

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final translator = di.sl<QuoteTranslationService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quoteMeaning),
        centerTitle: true,
        actions: [
          FavoriteButton(quoteId: quote.id),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          final prevLocale = previous is SettingsLoaded ? previous.locale : null;
          final currLocale = current is SettingsLoaded ? current.locale : null;
          return prevLocale != currLocale;
        },
        builder: (context, settingsState) {
          return SingleChildScrollView(
            child: ResponsiveCenter(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 32,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translator.getText(quote.id, quote.text),
                          style: AppTypography.quoteStyle(context).copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '- ${quote.author}',
                          style: AppTypography.authorStyle(context).copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.whatThisMeans,
                  style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  translator.getMeaning(quote.id, quote.meaning),
                  style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
