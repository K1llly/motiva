import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/streak.dart';
import '../repositories/streak_repository.dart';

class GetCurrentStreak implements UseCase<Streak, NoParams> {
  final StreakRepository repository;

  GetCurrentStreak(this.repository);

  @override
  Future<Either<Failure, Streak>> call(NoParams params) async {
    return await repository.getCurrentStreak();
  }
}
