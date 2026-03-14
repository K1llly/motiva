import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  final String quoteId;
  final double size;

  const FavoriteButton({
    super.key,
    required this.quoteId,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final isFav =
            state is FavoritesLoaded && state.isFavorite(quoteId);

        return IconButton(
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : null,
            size: size,
          ),
          onPressed: () {
            context
                .read<FavoritesBloc>()
                .add(ToggleFavoriteEvent(quoteId));
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFav ? l10n.removedFromFavorites : l10n.addedToFavorites,
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}
