import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/streak.dart';
import '../repositories/streak_repository.dart';

class IncrementStreak implements UseCase<Streak, NoParams> {
  final StreakRepository repository;

  IncrementStreak(this.repository);

  @override
  Future<Either<Failure, Streak>> call(NoParams params) async {
    // Get current streak
    final currentResult = await repository.getCurrentStreak();

    return currentResult.fold(
      (failure) => Left(failure),
      (currentStreak) async {
        // Business logic: Only increment if not already incremented today
        if (_alreadyIncrementedToday(currentStreak)) {
          return Right(currentStreak);
        }

        // Calculate new streak
        final newStreak = _calculateNewStreak(currentStreak);

        // Save and return
        return await repository.saveStreak(newStreak);
      },
    );
  }

  bool _alreadyIncrementedToday(Streak streak) {
    final now = DateTime.now();
    return streak.lastActiveDate.year == now.year &&
        streak.lastActiveDate.month == now.month &&
        streak.lastActiveDate.day == now.day;
  }

  Streak _calculateNewStreak(Streak current) {
    final now = DateTime.now();
    final daysSinceLastActive = now.difference(current.lastActiveDate).inDays;

    int newStreak;
    if (daysSinceLastActive <= 1) {
      newStreak = current.currentStreak + 1;
    } else {
      newStreak = 1; // Reset streak
    }

    return Streak(
      currentStreak: newStreak,
      longestStreak:
          newStreak > current.longestStreak ? newStreak : current.longestStreak,
      startDate: current.startDate,
      lastActiveDate: now,
      totalQuotesRead: current.totalQuotesRead + 1,
    );
  }
}
