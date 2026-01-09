import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stoic_mind/core/constants/notification_constants.dart';
import 'package:stoic_mind/core/constants/storage_keys.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SharedPreferences _sharedPreferences;

  NotificationRepositoryImpl(this._sharedPreferences);

  @override
  Future<Either<Failure, bool>> getNotificationsEnabled() async {
    try {
      final enabled = _sharedPreferences.getBool(StorageKeys.notificationsEnabled);
      return Right(enabled ?? true); // Default to enabled
    } catch (e) {
      return const Left(CacheFailure('Failed to get notification settings'));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled) async {
    try {
      await _sharedPreferences.setBool(StorageKeys.notificationsEnabled, enabled);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to save notification settings'));
    }
  }

  @override
  Future<Either<Failure, (int, int)>> getNotificationTime() async {
    try {
      final timeString = _sharedPreferences.getString(StorageKeys.notificationTime);

      if (timeString == null) {
        // Return default time (7:00 AM)
        return const Right((
          NotificationConstants.defaultHour,
          NotificationConstants.defaultMinute,
        ));
      }

      // Parse stored time format "HH:mm"
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return Right((hour, minute));
    } catch (e) {
      return const Left(CacheFailure('Failed to get notification time'));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationTime(int hour, int minute) async {
    try {
      final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      await _sharedPreferences.setString(StorageKeys.notificationTime, timeString);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to save notification time'));
    }
  }
}
