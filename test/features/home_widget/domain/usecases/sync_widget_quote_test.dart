import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/home_widget/domain/repositories/widget_repository.dart';
import 'package:stoic_mind/features/home_widget/domain/usecases/sync_widget_quote.dart';

class MockWidgetRepository extends Mock implements WidgetRepository {}

void main() {
  late SyncWidgetQuote usecase;
  late MockWidgetRepository mockRepository;

  setUp(() {
    mockRepository = MockWidgetRepository();
    usecase = SyncWidgetQuote(mockRepository);
  });

  test('should register widget callback via repository', () async {
    // arrange
    when(() => mockRepository.registerWidgetCallback())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.registerWidgetCallback()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return WidgetFailure when registration fails', () async {
    // arrange
    const tFailure = WidgetFailure('Failed to register callback');
    when(() => mockRepository.registerWidgetCallback())
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.registerWidgetCallback()).called(1);
  });
}
