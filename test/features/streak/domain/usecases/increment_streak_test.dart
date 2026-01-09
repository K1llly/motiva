import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/domain/repositories/streak_repository.dart';
import 'package:stoic_mind/features/streak/domain/usecases/increment_streak.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

class FakeStreak extends Fake implements Streak {}

void main() {
  late IncrementStreak usecase;
  late MockStreakRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeStreak());
  });

  setUp(() {
    mockRepository = MockStreakRepository();
    usecase = IncrementStreak(mockRepository);
  });

  group('IncrementStreak', () {
    test('should return current streak if already incremented today', () async {
      // arrange
      final now = DateTime.now();
      final todayStreak = Streak(
        currentStreak: 5,
        longestStreak: 10,
        startDate: now.subtract(const Duration(days: 30)),
        lastActiveDate: now, // Already updated today
        totalQuotesRead: 25,
      );

      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => Right(todayStreak));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, Right(todayStreak));
      verify(() => mockRepository.getCurrentStreak()).called(1);
      verifyNever(() => mockRepository.saveStreak(any()));
    });

    test('should increment streak when last active was yesterday', () async {
      // arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStreak = Streak(
        currentStreak: 5,
        longestStreak: 10,
        startDate: yesterday.subtract(const Duration(days: 30)),
        lastActiveDate: yesterday,
        totalQuotesRead: 25,
      );

      final incrementedStreak = Streak(
        currentStreak: 6,
        longestStreak: 10,
        startDate: yesterdayStreak.startDate,
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 26,
      );

      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => Right(yesterdayStreak));
      when(() => mockRepository.saveStreak(any()))
          .thenAnswer((_) async => Right(incrementedStreak));

      // act
      final result = await usecase(const NoParams());

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (streak) {
          expect(streak.currentStreak, 6);
          expect(streak.totalQuotesRead, 26);
        },
      );
      verify(() => mockRepository.getCurrentStreak()).called(1);
      verify(() => mockRepository.saveStreak(any())).called(1);
    });

    test('should reset streak to 1 when last active was more than 1 day ago', () async {
      // arrange
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final oldStreak = Streak(
        currentStreak: 5,
        longestStreak: 10,
        startDate: twoDaysAgo.subtract(const Duration(days: 30)),
        lastActiveDate: twoDaysAgo,
        totalQuotesRead: 25,
      );

      final resetStreak = Streak(
        currentStreak: 1,
        longestStreak: 10,
        startDate: oldStreak.startDate,
        lastActiveDate: DateTime.now(),
        totalQuotesRead: 26,
      );

      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => Right(oldStreak));
      when(() => mockRepository.saveStreak(any()))
          .thenAnswer((_) async => Right(resetStreak));

      // act
      final result = await usecase(const NoParams());

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (streak) {
          expect(streak.currentStreak, 1);
          expect(streak.totalQuotesRead, 26);
        },
      );
    });

    test('should update longestStreak when current exceeds it', () async {
      // arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final streak = Streak(
        currentStreak: 10,
        longestStreak: 10,
        startDate: yesterday.subtract(const Duration(days: 30)),
        lastActiveDate: yesterday,
        totalQuotesRead: 50,
      );

      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => Right(streak));
      when(() => mockRepository.saveStreak(any()))
          .thenAnswer((invocation) async {
        final savedStreak = invocation.positionalArguments[0] as Streak;
        return Right(savedStreak);
      });

      // act
      final result = await usecase(const NoParams());

      // assert
      result.fold(
        (failure) => fail('Should not return failure'),
        (streak) {
          expect(streak.currentStreak, 11);
          expect(streak.longestStreak, 11);
        },
      );
    });

    test('should return failure when getting current streak fails', () async {
      // arrange
      const tFailure = CacheFailure('Failed to get streak');
      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
      verifyNever(() => mockRepository.saveStreak(any()));
    });

    test('should return failure when saving streak fails', () async {
      // arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final streak = Streak(
        currentStreak: 5,
        longestStreak: 10,
        startDate: yesterday.subtract(const Duration(days: 30)),
        lastActiveDate: yesterday,
        totalQuotesRead: 25,
      );

      const tFailure = CacheFailure('Failed to save streak');

      when(() => mockRepository.getCurrentStreak())
          .thenAnswer((_) async => Right(streak));
      when(() => mockRepository.saveStreak(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const NoParams());

      // assert
      expect(result, const Left(tFailure));
    });
  });
}
