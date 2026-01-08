import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/streak.dart';
import '../repositories/streak_repository.dart';

class ResetStreak implements UseCase<Streak, NoParams> {
  final StreakRepository repository;

  ResetStreak(this.repository);

  @override
  Future<Either<Failure, Streak>> call(NoParams params) async {
    return await repository.resetStreak();
  }
}
