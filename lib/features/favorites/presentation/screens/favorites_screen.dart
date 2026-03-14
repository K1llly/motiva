import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../../core/services/quote_translation_service.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../quote/data/datasources/quote_local_datasource.dart';
import '../../../quote/domain/entities/quote.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/favorite_button.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          final prevLocale = previous is SettingsLoaded ? previous.locale : null;
          final currLocale = current is SettingsLoaded ? current.locale : null;
          return prevLocale != currLocale;
        },
        builder: (context, _) {
          return BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              if (state is! FavoritesLoaded || state.favoriteIds.isEmpty) {
                return _EmptyFavoritesView(l10n: l10n);
              }

              return _FavoritesList(favoriteIds: state.favoriteIds.toList());
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyFavoritesView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveCenter(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noFavorites,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noFavoritesDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<String> favoriteIds;

  const _FavoritesList({required this.favoriteIds});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteIds.length,
        itemBuilder: (context, index) {
          return _FavoriteQuoteTile(quoteId: favoriteIds[index]);
        },
      ),
    );
  }
}

class _FavoriteQuoteTile extends StatelessWidget {
  final String quoteId;

  const _FavoriteQuoteTile({required this.quoteId});

  @override
  Widget build(BuildContext context) {
    final dataSource = di.sl<QuoteLocalDataSource>();
    final translator = di.sl<QuoteTranslationService>();
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Quote>(
      future: dataSource.getQuoteById(quoteId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final quote = snapshot.data!;
        final displayText = translator.getText(quote.id, quote.text);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/quote-detail',
                arguments: quote,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: AppTypography.quoteStyle(context).copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '- ${quote.author}',
                          style: AppTypography.authorStyle(context).copyWith(
                            color: colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(quoteId: quoteId, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
