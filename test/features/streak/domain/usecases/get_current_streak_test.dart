import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/domain/repositories/streak_repository.dart';
import 'package:stoic_mind/features/streak/domain/usecases/get_current_streak.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late GetCurrentStreak usecase;
  late MockStreakRepository mockRepository;

  setUp(() {
    mockRepository = MockStreakRepository();
    usecase = GetCurrentStreak(mockRepository);
  });

  final tStreak = Streak(
    currentStreak: 5,
    longestStreak: 10,
    startDate: DateTime.now(),
    lastActiveDate: DateTime.now(),
    totalQuotesRead: 25,
  );

  test('should get current streak from the repository', () async {
    // arrange
    when(() => mockRepository.getCurrentStreak())
        .thenAnswer((_) async => Right(tStreak));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, Right(tStreak));
    verify(() => mockRepository.getCurrentStreak()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to get streak');
    when(() => mockRepository.getCurrentStreak())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getCurrentStreak()).called(1);
  });
}
