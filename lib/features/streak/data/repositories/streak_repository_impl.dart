import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/streak.dart';
import '../../domain/repositories/streak_repository.dart';
import '../datasources/streak_local_datasource.dart';
import '../models/streak_model.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakLocalDataSource localDataSource;

  StreakRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Streak>> getCurrentStreak() async {
    try {
      final streak = await localDataSource.getStreak();
      return Right(streak);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Streak>> saveStreak(Streak streak) async {
    try {
      final streakModel = StreakModel.fromEntity(streak);
      await localDataSource.saveStreak(streakModel);
      return Right(streak);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Streak>> resetStreak() async {
    try {
      await localDataSource.resetStreak();
      final newStreak = await localDataSource.getStreak();
      return Right(newStreak);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
