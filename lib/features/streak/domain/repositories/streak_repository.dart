import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/streak.dart';

/// Repository contract for streak operations
abstract class StreakRepository {
  /// Get current streak data
  Future<Either<Failure, Streak>> getCurrentStreak();

  /// Save streak data
  Future<Either<Failure, Streak>> saveStreak(Streak streak);

  /// Reset streak to zero
  Future<Either<Failure, Streak>> resetStreak();
}
