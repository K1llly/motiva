import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteIds;

  const FavoritesLoaded(this.favoriteIds);

  bool isFavorite(String quoteId) => favoriteIds.contains(quoteId);

  @override
  List<Object?> get props => [favoriteIds];
}
