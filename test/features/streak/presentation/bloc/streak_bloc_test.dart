import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/domain/usecases/get_current_streak.dart';
import 'package:stoic_mind/features/streak/domain/usecases/increment_streak.dart';
import 'package:stoic_mind/features/streak/domain/usecases/reset_streak.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_event.dart';
import 'package:stoic_mind/features/streak/presentation/bloc/streak_state.dart';

class MockGetCurrentStreak extends Mock implements GetCurrentStreak {}

class MockIncrementStreak extends Mock implements IncrementStreak {}

class MockResetStreak extends Mock implements ResetStreak {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late StreakBloc bloc;
  late MockGetCurrentStreak mockGetCurrentStreak;
  late MockIncrementStreak mockIncrementStreak;
  late MockResetStreak mockResetStreak;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetCurrentStreak = MockGetCurrentStreak();
    mockIncrementStreak = MockIncrementStreak();
    mockResetStreak = MockResetStreak();

    bloc = StreakBloc(
      getCurrentStreak: mockGetCurrentStreak,
      incrementStreak: mockIncrementStreak,
      resetStreak: mockResetStreak,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tStreak = Streak(
    currentStreak: 5,
    longestStreak: 10,
    startDate: DateTime.now(),
    lastActiveDate: DateTime.now(),
    totalQuotesRead: 25,
  );

  test('initial state should be StreakInitial', () {
    expect(bloc.state, const StreakInitial());
  });

  group('LoadStreakEvent', () {
    blocTest<StreakBloc, StreakState>(
      'emits [StreakLoading, StreakLoaded] when streak is loaded successfully',
      build: () {
        when(() => mockGetCurrentStreak(any()))
            .thenAnswer((_) async => Right(tStreak));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadStreakEvent()),
      expect: () => [
        const StreakLoading(),
        StreakLoaded(tStreak),
      ],
      verify: (_) {
        verify(() => mockGetCurrentStreak(any())).called(1);
      },
    );

    blocTest<StreakBloc, StreakState>(
      'emits [StreakLoading, StreakError] when loading streak fails',
      build: () {
        when(() => mockGetCurrentStreak(any()))
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadStreakEvent()),
      expect: () => [
        const StreakLoading(),
        const StreakError('Cache error'),
      ],
    );
  });

  group('IncrementStreakEvent', () {
    final incrementedStreak = Streak(
      currentStreak: 6,
      longestStreak: 10,
      startDate: tStreak.startDate,
      lastActiveDate: DateTime.now(),
      totalQuotesRead: 26,
    );

    blocTest<StreakBloc, StreakState>(
      'emits [StreakLoaded] when streak is incremented successfully',
      build: () {
        when(() => mockIncrementStreak(any()))
            .thenAnswer((_) async => Right(incrementedStreak));
        return bloc;
      },
      act: (bloc) => bloc.add(const IncrementStreakEvent()),
      expect: () => [
        StreakLoaded(incrementedStreak),
      ],
      verify: (_) {
        verify(() => mockIncrementStreak(any())).called(1);
      },
    );

    blocTest<StreakBloc, StreakState>(
      'emits [StreakError] when increment fails',
      build: () {
        when(() => mockIncrementStreak(any()))
            .thenAnswer((_) async => const Left(CacheFailure('Failed to increment')));
        return bloc;
      },
      act: (bloc) => bloc.add(const IncrementStreakEvent()),
      expect: () => [
        const StreakError('Failed to increment'),
      ],
    );
  });

  group('ResetStreakEvent', () {
    final resetStreak = Streak(
      currentStreak: 0,
      longestStreak: 10,
      startDate: DateTime.now(),
      lastActiveDate: DateTime.now(),
      totalQuotesRead: 25,
    );

    blocTest<StreakBloc, StreakState>(
      'emits [StreakLoaded] when streak is reset successfully',
      build: () {
        when(() => mockResetStreak(any()))
            .thenAnswer((_) async => Right(resetStreak));
        return bloc;
      },
      act: (bloc) => bloc.add(const ResetStreakEvent()),
      expect: () => [
        StreakLoaded(resetStreak),
      ],
      verify: (_) {
        verify(() => mockResetStreak(any())).called(1);
      },
    );

    blocTest<StreakBloc, StreakState>(
      'emits [StreakError] when reset fails',
      build: () {
        when(() => mockResetStreak(any()))
            .thenAnswer((_) async => const Left(CacheFailure('Failed to reset')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ResetStreakEvent()),
      expect: () => [
        const StreakError('Failed to reset'),
      ],
    );
  });
}
