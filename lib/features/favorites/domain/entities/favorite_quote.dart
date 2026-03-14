import 'package:equatable/equatable.dart';

class FavoriteQuote extends Equatable {
  final String quoteId;
  final DateTime favoritedAt;

  const FavoriteQuote({
    required this.quoteId,
    required this.favoritedAt,
  });

  @override
  List<Object?> get props => [quoteId, favoritedAt];
}
