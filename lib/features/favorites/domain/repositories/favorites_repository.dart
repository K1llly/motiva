import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, Set<String>>> getFavoriteIds();
  Future<Either<Failure, bool>> toggleFavorite(String quoteId);
  Future<Either<Failure, bool>> isFavorite(String quoteId);
}
