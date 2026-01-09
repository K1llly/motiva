import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/domain/repositories/streak_repository.dart';
import 'package:stoic_mind/features/streak/domain/usecases/reset_streak.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late ResetStreak usecase;
  late MockStreakRepository mockRepository;

  setUp(() {
    mockRepository = MockStreakRepository();
    usecase = ResetStreak(mockRepository);
  });

  final tResetStreak = Streak(
    currentStreak: 0,
    longestStreak: 10,
    startDate: DateTime.now(),
    lastActiveDate: DateTime.now(),
    totalQuotesRead: 25,
  );

  test('should reset streak via repository', () async {
    // arrange
    when(() => mockRepository.resetStreak())
        .thenAnswer((_) async => Right(tResetStreak));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, Right(tResetStreak));
    verify(() => mockRepository.resetStreak()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to reset streak');
    when(() => mockRepository.resetStreak())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.resetStreak()).called(1);
  });
}
