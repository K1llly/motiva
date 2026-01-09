import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/domain/usecases/get_daily_quote.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_bloc.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_event.dart';
import 'package:stoic_mind/features/quote/presentation/bloc/quote_state.dart';
import 'package:stoic_mind/features/streak/domain/entities/streak.dart';
import 'package:stoic_mind/features/streak/domain/usecases/increment_streak.dart';
import 'package:stoic_mind/features/home_widget/domain/usecases/update_widget_data.dart';

class MockGetDailyQuote extends Mock implements GetDailyQuote {}

class MockIncrementStreak extends Mock implements IncrementStreak {}

class MockUpdateWidgetData extends Mock implements UpdateWidgetData {}

class FakeGetDailyQuoteParams extends Fake implements GetDailyQuoteParams {}

class FakeNoParams extends Fake implements NoParams {}

class FakeUpdateWidgetParams extends Fake implements UpdateWidgetParams {}

void main() {
  late QuoteBloc bloc;
  late MockGetDailyQuote mockGetDailyQuote;
  late MockIncrementStreak mockIncrementStreak;
  late MockUpdateWidgetData mockUpdateWidgetData;
  late int Function() mockGetCurrentDayNumber;

  setUpAll(() {
    registerFallbackValue(FakeGetDailyQuoteParams());
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeUpdateWidgetParams());
  });

  setUp(() {
    mockGetDailyQuote = MockGetDailyQuote();
    mockIncrementStreak = MockIncrementStreak();
    mockUpdateWidgetData = MockUpdateWidgetData();
    mockGetCurrentDayNumber = () => 1;

    bloc = QuoteBloc(
      getDailyQuote: mockGetDailyQuote,
      incrementStreak: mockIncrementStreak,
      updateWidgetData: mockUpdateWidgetData,
      getCurrentDayNumber: mockGetCurrentDayNumber,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tQuote = Quote(
    id: '1',
    text: 'Test quote',
    author: 'Test Author',
    meaning: 'Test meaning',
    dayNumber: 1,
  );

  final tStreak = Streak(
    currentStreak: 1,
    longestStreak: 1,
    startDate: DateTime.now(),
    lastActiveDate: DateTime.now(),
    totalQuotesRead: 1,
  );

  test('initial state should be QuoteInitial', () {
    expect(bloc.state, const QuoteInitial());
  });

  group('LoadDailyQuoteEvent', () {
    blocTest<QuoteBloc, QuoteState>(
      'emits [QuoteLoading, QuoteLoaded] when quote is loaded successfully',
      build: () {
        when(() => mockGetDailyQuote(any()))
            .thenAnswer((_) async => const Right(tQuote));
        when(() => mockIncrementStreak(any()))
            .thenAnswer((_) async => Right(tStreak));
        when(() => mockUpdateWidgetData(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDailyQuoteEvent()),
      expect: () => [
        const QuoteLoading(),
        const QuoteLoaded(quote: tQuote),
      ],
      verify: (_) {
        verify(() => mockGetDailyQuote(any())).called(1);
        verify(() => mockIncrementStreak(any())).called(1);
        verify(() => mockUpdateWidgetData(any())).called(1);
      },
    );

    blocTest<QuoteBloc, QuoteState>(
      'emits [QuoteLoading, QuoteError] when loading quote fails',
      build: () {
        when(() => mockGetDailyQuote(any()))
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDailyQuoteEvent()),
      expect: () => [
        const QuoteLoading(),
        const QuoteError('Could not load quote. Please try again.'),
      ],
    );

    blocTest<QuoteBloc, QuoteState>(
      'emits correct error message for WidgetFailure',
      build: () {
        when(() => mockGetDailyQuote(any()))
            .thenAnswer((_) async => const Left(WidgetFailure('Widget error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDailyQuoteEvent()),
      expect: () => [
        const QuoteLoading(),
        const QuoteError('Widget update failed. Quote loaded successfully.'),
      ],
    );

    blocTest<QuoteBloc, QuoteState>(
      'emits correct error message for UnexpectedFailure',
      build: () {
        when(() => mockGetDailyQuote(any())).thenAnswer(
            (_) async => const Left(UnexpectedFailure('Unexpected error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadDailyQuoteEvent()),
      expect: () => [
        const QuoteLoading(),
        const QuoteError('An unexpected error occurred.'),
      ],
    );
  });

  group('ViewQuoteMeaningEvent', () {
    blocTest<QuoteBloc, QuoteState>(
      'does not emit new states for ViewQuoteMeaningEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(const ViewQuoteMeaningEvent('1')),
      expect: () => [],
    );
  });

  group('RefreshQuoteEvent', () {
    blocTest<QuoteBloc, QuoteState>(
      'triggers LoadDailyQuoteEvent when RefreshQuoteEvent is added',
      build: () {
        when(() => mockGetDailyQuote(any()))
            .thenAnswer((_) async => const Right(tQuote));
        when(() => mockIncrementStreak(any()))
            .thenAnswer((_) async => Right(tStreak));
        when(() => mockUpdateWidgetData(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshQuoteEvent()),
      expect: () => [
        const QuoteLoading(),
        const QuoteLoaded(quote: tQuote),
      ],
    );
  });
}
