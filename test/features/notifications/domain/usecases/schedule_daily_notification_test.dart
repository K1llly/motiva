import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stoic_mind/features/notifications/domain/usecases/schedule_daily_notification.dart';
import 'package:stoic_mind/features/notifications/presentation/services/notification_service.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/domain/usecases/get_daily_quote.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockGetDailyQuote extends Mock implements GetDailyQuote {}

class FakeGetDailyQuoteParams extends Fake implements GetDailyQuoteParams {}

void main() {
  late ScheduleDailyNotification usecase;
  late MockNotificationService mockNotificationService;
  late MockNotificationRepository mockNotificationRepository;
  late MockGetDailyQuote mockGetDailyQuote;
  late int Function() mockGetCurrentDayNumber;

  const tQuote = Quote(
    id: '1',
    text: 'The obstacle is the way.',
    author: 'Marcus Aurelius',
    meaning: 'Challenges are opportunities.',
    dayNumber: 1,
  );

  setUpAll(() {
    registerFallbackValue(FakeGetDailyQuoteParams());
  });

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockNotificationRepository = MockNotificationRepository();
    mockGetDailyQuote = MockGetDailyQuote();
    mockGetCurrentDayNumber = () => 1;

    usecase = ScheduleDailyNotification(
      notificationService: mockNotificationService,
      notificationRepository: mockNotificationRepository,
      getDailyQuote: mockGetDailyQuote,
      getCurrentDayNumber: mockGetCurrentDayNumber,
    );
  });

  group('ScheduleDailyNotification', () {
    test('should schedule notification when notifications are enabled',
        () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockNotificationRepository.getNotificationTime())
          .thenAnswer((_) async => const Right((7, 0)));
      when(() => mockGetDailyQuote(any()))
          .thenAnswer((_) async => const Right(tQuote));
      when(() => mockNotificationService.scheduleDailyNotification(
            quoteText: any(named: 'quoteText'),
            author: any(named: 'author'),
            hour: any(named: 'hour'),
            minute: any(named: 'minute'),
          )).thenAnswer((_) async {});

      // act
      final result = await usecase(const ScheduleNotificationParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockNotificationService.scheduleDailyNotification(
            quoteText: tQuote.text,
            author: tQuote.author,
            hour: 7,
            minute: 0,
          )).called(1);
    });

    test('should not schedule notification when notifications are disabled',
        () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await usecase(const ScheduleNotificationParams());

      // assert
      expect(result, const Right(null));
      verifyNever(() => mockNotificationService.scheduleDailyNotification(
            quoteText: any(named: 'quoteText'),
            author: any(named: 'author'),
            hour: any(named: 'hour'),
            minute: any(named: 'minute'),
          ));
    });

    test('should use provided quote when passed in params', () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockNotificationRepository.getNotificationTime())
          .thenAnswer((_) async => const Right((8, 30)));
      when(() => mockNotificationService.scheduleDailyNotification(
            quoteText: any(named: 'quoteText'),
            author: any(named: 'author'),
            hour: any(named: 'hour'),
            minute: any(named: 'minute'),
          )).thenAnswer((_) async {});

      // act
      final result =
          await usecase(const ScheduleNotificationParams(quote: tQuote));

      // assert
      expect(result, const Right(null));
      verifyNever(() => mockGetDailyQuote(any()));
      verify(() => mockNotificationService.scheduleDailyNotification(
            quoteText: tQuote.text,
            author: tQuote.author,
            hour: 8,
            minute: 30,
          )).called(1);
    });

    test('should return failure when getNotificationsEnabled fails', () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer(
              (_) async => const Left(CacheFailure('Failed to get settings')));

      // act
      final result = await usecase(const ScheduleNotificationParams());

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return failure when getNotificationTime fails', () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockNotificationRepository.getNotificationTime()).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to get time')));

      // act
      final result = await usecase(const ScheduleNotificationParams());

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return failure when getDailyQuote fails', () async {
      // arrange
      when(() => mockNotificationRepository.getNotificationsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockNotificationRepository.getNotificationTime())
          .thenAnswer((_) async => const Right((7, 0)));
      when(() => mockGetDailyQuote(any())).thenAnswer(
          (_) async => const Left(CacheFailure('Failed to get quote')));

      // act
      final result = await usecase(const ScheduleNotificationParams());

      // assert
      expect(result.isLeft(), true);
    });
  });

  group('ScheduleNotificationParams', () {
    test('should support equality', () {
      const params1 = ScheduleNotificationParams(quote: tQuote);
      const params2 = ScheduleNotificationParams(quote: tQuote);
      const params3 = ScheduleNotificationParams();

      expect(params1, params2);
      expect(params1, isNot(params3));
    });

    test('should have correct props', () {
      const params = ScheduleNotificationParams(quote: tQuote);
      expect(params.props, [tQuote]);
    });
  });

  group('NotificationFailure', () {
    test('should be a Failure', () {
      const failure = NotificationFailure('Test error');
      expect(failure, isA<Failure>());
      expect(failure.message, 'Test error');
    });
  });
}
