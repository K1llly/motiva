import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

class IsFavorite extends UseCase<bool, String> {
  final FavoritesRepository repository;

  IsFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(String quoteId) {
    return repository.isFavorite(quoteId);
  }
}
