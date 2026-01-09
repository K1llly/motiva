import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/domain/repositories/quote_repository.dart';
import 'package:stoic_mind/features/quote/domain/usecases/get_daily_quote.dart';

class MockQuoteRepository extends Mock implements QuoteRepository {}

void main() {
  late GetDailyQuote usecase;
  late MockQuoteRepository mockRepository;

  setUp(() {
    mockRepository = MockQuoteRepository();
    usecase = GetDailyQuote(mockRepository);
  });

  const tDayNumber = 1;
  const tQuote = Quote(
    id: '1',
    text: 'Test quote',
    author: 'Test Author',
    meaning: 'Test meaning',
    dayNumber: 1,
  );

  test('should get daily quote from the repository', () async {
    // arrange
    when(() => mockRepository.getDailyQuote(any()))
        .thenAnswer((_) async => const Right(tQuote));

    // act
    final result = await usecase(const GetDailyQuoteParams(dayNumber: tDayNumber));

    // assert
    expect(result, const Right(tQuote));
    verify(() => mockRepository.getDailyQuote(tDayNumber)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when repository fails', () async {
    // arrange
    const tFailure = CacheFailure('Cache error');
    when(() => mockRepository.getDailyQuote(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const GetDailyQuoteParams(dayNumber: tDayNumber));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getDailyQuote(tDayNumber)).called(1);
  });

  test('GetDailyQuoteParams should store dayNumber correctly', () {
    const params = GetDailyQuoteParams(dayNumber: 42);
    expect(params.dayNumber, 42);
  });
}
