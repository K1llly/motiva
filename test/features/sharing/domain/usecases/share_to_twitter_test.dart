import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/sharing/domain/entities/share_content.dart';
import 'package:stoic_mind/features/sharing/domain/repositories/share_repository.dart';
import 'package:stoic_mind/features/sharing/domain/usecases/share_to_twitter.dart';

class MockShareRepository extends Mock implements ShareRepository {}

class FakeShareContent extends Fake implements ShareContent {}

void main() {
  late ShareToTwitter usecase;
  late MockShareRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeShareContent());
  });

  setUp(() {
    mockRepository = MockShareRepository();
    usecase = ShareToTwitter(mockRepository);
  });

  const tShareContent = ShareContent(
    text: '"Test quote" - Author',
    platform: SharePlatform.twitter,
  );

  test('should share to Twitter via repository', () async {
    // arrange
    when(() => mockRepository.shareToTwitter(any()))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(tShareContent);

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.shareToTwitter(tShareContent)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ShareFailure when sharing fails', () async {
    // arrange
    const tFailure = ShareFailure('Failed to share to Twitter');
    when(() => mockRepository.shareToTwitter(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(tShareContent);

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.shareToTwitter(tShareContent)).called(1);
  });
}
