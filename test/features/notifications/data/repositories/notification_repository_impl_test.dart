import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic_mind/core/constants/notification_constants.dart';
import 'package:stoic_mind/core/constants/storage_keys.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/notifications/data/repositories/notification_repository_impl.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    repository = NotificationRepositoryImpl(mockSharedPreferences);
  });

  group('getNotificationsEnabled', () {
    test('should return true when notifications are enabled', () async {
      // arrange
      when(() => mockSharedPreferences.getBool(StorageKeys.notificationsEnabled))
          .thenReturn(true);

      // act
      final result = await repository.getNotificationsEnabled();

      // assert
      expect(result, const Right(true));
      verify(() => mockSharedPreferences.getBool(StorageKeys.notificationsEnabled))
          .called(1);
    });

    test('should return false when notifications are disabled', () async {
      // arrange
      when(() => mockSharedPreferences.getBool(StorageKeys.notificationsEnabled))
          .thenReturn(false);

      // act
      final result = await repository.getNotificationsEnabled();

      // assert
      expect(result, const Right(false));
    });

    test('should return true (default) when no preference is set', () async {
      // arrange
      when(() => mockSharedPreferences.getBool(StorageKeys.notificationsEnabled))
          .thenReturn(null);

      // act
      final result = await repository.getNotificationsEnabled();

      // assert
      expect(result, const Right(true));
    });

    test('should return CacheFailure on exception', () async {
      // arrange
      when(() => mockSharedPreferences.getBool(StorageKeys.notificationsEnabled))
          .thenThrow(Exception('Test error'));

      // act
      final result = await repository.getNotificationsEnabled();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('setNotificationsEnabled', () {
    test('should save notification enabled state', () async {
      // arrange
      when(() => mockSharedPreferences.setBool(
              StorageKeys.notificationsEnabled, true))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.setNotificationsEnabled(true);

      // assert
      expect(result, const Right(null));
      verify(() => mockSharedPreferences.setBool(
              StorageKeys.notificationsEnabled, true))
          .called(1);
    });

    test('should return CacheFailure on exception', () async {
      // arrange
      when(() => mockSharedPreferences.setBool(
              StorageKeys.notificationsEnabled, true))
          .thenThrow(Exception('Test error'));

      // act
      final result = await repository.setNotificationsEnabled(true);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('getNotificationTime', () {
    test('should return stored time when available', () async {
      // arrange
      when(() => mockSharedPreferences.getString(StorageKeys.notificationTime))
          .thenReturn('08:30');

      // act
      final result = await repository.getNotificationTime();

      // assert
      expect(result, const Right((8, 30)));
    });

    test('should return default time (7:00) when no time is set', () async {
      // arrange
      when(() => mockSharedPreferences.getString(StorageKeys.notificationTime))
          .thenReturn(null);

      // act
      final result = await repository.getNotificationTime();

      // assert
      expect(
        result,
        const Right((
          NotificationConstants.defaultHour,
          NotificationConstants.defaultMinute,
        )),
      );
    });

    test('should parse time with leading zeros correctly', () async {
      // arrange
      when(() => mockSharedPreferences.getString(StorageKeys.notificationTime))
          .thenReturn('07:05');

      // act
      final result = await repository.getNotificationTime();

      // assert
      expect(result, const Right((7, 5)));
    });

    test('should return CacheFailure on exception', () async {
      // arrange
      when(() => mockSharedPreferences.getString(StorageKeys.notificationTime))
          .thenThrow(Exception('Test error'));

      // act
      final result = await repository.getNotificationTime();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });

  group('setNotificationTime', () {
    test('should save notification time in correct format', () async {
      // arrange
      when(() => mockSharedPreferences.setString(
              StorageKeys.notificationTime, '08:30'))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.setNotificationTime(8, 30);

      // assert
      expect(result, const Right(null));
      verify(() => mockSharedPreferences.setString(
              StorageKeys.notificationTime, '08:30'))
          .called(1);
    });

    test('should pad single digit hours and minutes with zeros', () async {
      // arrange
      when(() => mockSharedPreferences.setString(
              StorageKeys.notificationTime, '07:05'))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.setNotificationTime(7, 5);

      // assert
      expect(result, const Right(null));
      verify(() => mockSharedPreferences.setString(
              StorageKeys.notificationTime, '07:05'))
          .called(1);
    });

    test('should return CacheFailure on exception', () async {
      // arrange
      when(() => mockSharedPreferences.setString(
              StorageKeys.notificationTime, '08:30'))
          .thenThrow(Exception('Test error'));

      // act
      final result = await repository.setNotificationTime(8, 30);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
