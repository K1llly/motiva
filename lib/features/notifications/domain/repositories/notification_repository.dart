import 'package:dartz/dartz.dart';
import 'package:stoic_mind/core/errors/failures.dart';

abstract class NotificationRepository {
  /// Get whether notifications are enabled
  Future<Either<Failure, bool>> getNotificationsEnabled();

  /// Set notifications enabled/disabled
  Future<Either<Failure, void>> setNotificationsEnabled(bool enabled);

  /// Get notification time (hour, minute)
  Future<Either<Failure, (int, int)>> getNotificationTime();

  /// Set notification time
  Future<Either<Failure, void>> setNotificationTime(int hour, int minute);
}
