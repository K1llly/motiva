import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/home_widget/domain/repositories/widget_repository.dart';
import 'package:stoic_mind/features/home_widget/domain/usecases/update_widget_data.dart';

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late UpdateWidgetData usecase;
  late MockWidgetRepository mockRepository;

  setUp(() {
    mockRepository = MockWidgetRepository();
    usecase = UpdateWidgetData(mockRepository);
  });

  const tParams = UpdateWidgetParams(
    quoteText: 'Test quote',
    author: 'Test Author',
    dayNumber: 1,
  );

  test('should update widget data via repository', () async {
    // arrange
    when(() => mockRepository.updateWidgetData(
          quoteText: any(named: 'quoteText'),
          author: any(named: 'author'),
          dayNumber: any(named: 'dayNumber'),
        )).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.updateWidgetData(
          quoteText: tParams.quoteText,
          author: tParams.author,
          dayNumber: tParams.dayNumber,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return WidgetFailure when update fails', () async {
    // arrange
    const tFailure = WidgetFailure('Failed to update widget');
    when(() => mockRepository.updateWidgetData(
          quoteText: any(named: 'quoteText'),
          author: any(named: 'author'),
          dayNumber: any(named: 'dayNumber'),
        )).thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(tFailure));
  });

  group('UpdateWidgetParams', () {
    test('should store all parameters correctly', () {
      const params = UpdateWidgetParams(
        quoteText: 'Quote',
        author: 'Author',
        dayNumber: 42,
      );

      expect(params.quoteText, 'Quote');
      expect(params.author, 'Author');
      expect(params.dayNumber, 42);
    });
  });
}
