import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String quoteId;

  const ToggleFavoriteEvent(this.quoteId);

  @override
  List<Object?> get props => [quoteId];
}
