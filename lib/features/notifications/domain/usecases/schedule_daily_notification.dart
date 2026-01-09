import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stoic_mind/features/notifications/presentation/services/notification_service.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/domain/usecases/get_daily_quote.dart';

class ScheduleDailyNotification implements UseCase<void, ScheduleNotificationParams> {
  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;
  final GetDailyQuote _getDailyQuote;
  final int Function() _getCurrentDayNumber;

  ScheduleDailyNotification({
    required NotificationService notificationService,
    required NotificationRepository notificationRepository,
    required GetDailyQuote getDailyQuote,
    required int Function() getCurrentDayNumber,
  })  : _notificationService = notificationService,
        _notificationRepository = notificationRepository,
        _getDailyQuote = getDailyQuote,
        _getCurrentDayNumber = getCurrentDayNumber;

  @override
  Future<Either<Failure, void>> call(ScheduleNotificationParams params) async {
    try {
      // Check if notifications are enabled
      final enabledResult = await _notificationRepository.getNotificationsEnabled();

      return enabledResult.fold(
        (failure) => Left(failure),
        (enabled) async {
          if (!enabled) {
            return const Right(null); // Notifications disabled, nothing to do
          }

          // Get notification time
          final timeResult = await _notificationRepository.getNotificationTime();

          return timeResult.fold(
            (failure) => Left(failure),
            (time) async {
              final (hour, minute) = time;

              // Get today's quote for the notification
              Quote quote;
              if (params.quote != null) {
                quote = params.quote!;
              } else {
                final dayNumber = _getCurrentDayNumber();
                final quoteResult = await _getDailyQuote(
                  GetDailyQuoteParams(dayNumber: dayNumber),
                );
                final quoteOrFailure = quoteResult.fold(
                  (failure) => failure,
                  (q) => q,
                );

                if (quoteOrFailure is Failure) {
                  return Left(quoteOrFailure);
                }
                quote = quoteOrFailure as Quote;
              }

              // Schedule the notification
              await _notificationService.scheduleDailyNotification(
                quoteText: quote.text,
                author: quote.author,
                hour: hour,
                minute: minute,
              );

              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      return Left(NotificationFailure('Failed to schedule notification: $e'));
    }
  }
}

class ScheduleNotificationParams extends Equatable {
  final Quote? quote;

  const ScheduleNotificationParams({this.quote});

  @override
  List<Object?> get props => [quote];
}

/// Failure specific to notification operations
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}
