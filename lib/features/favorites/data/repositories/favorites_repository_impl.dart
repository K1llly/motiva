import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource dataSource;

  FavoritesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Set<String>>> getFavoriteIds() async {
    try {
      final ids = await dataSource.getFavoriteIds();
      return Right(ids);
    } catch (e) {
      return const Left(CacheFailure('Failed to load favorites'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String quoteId) async {
    try {
      final isFav = await dataSource.toggleFavorite(quoteId);
      return Right(isFav);
    } catch (e) {
      return const Left(CacheFailure('Failed to toggle favorite'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String quoteId) async {
    try {
      final isFav = await dataSource.isFavorite(quoteId);
      return Right(isFav);
    } catch (e) {
      return const Left(CacheFailure('Failed to check favorite'));
    }
  }
}
