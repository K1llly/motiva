import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/core/services/quote_translation_service.dart';
import 'package:stoic_mind/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stoic_mind/features/notifications/presentation/services/notification_service.dart';
import 'package:stoic_mind/features/quote/domain/entities/quote.dart';
import 'package:stoic_mind/features/quote/domain/usecases/get_daily_quote.dart';

class ScheduleDailyNotification implements UseCase<void, ScheduleNotificationParams> {
  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;
  final GetDailyQuote _getDailyQuote;
  final int Function() _getCurrentDayNumber;
  final QuoteTranslationService _translationService;

  ScheduleDailyNotification({
    required NotificationService notificationService,
    required NotificationRepository notificationRepository,
    required GetDailyQuote getDailyQuote,
    required int Function() getCurrentDayNumber,
    required QuoteTranslationService translationService,
  })  : _notificationService = notificationService,
        _notificationRepository = notificationRepository,
        _getDailyQuote = getDailyQuote,
        _getCurrentDayNumber = getCurrentDayNumber,
        _translationService = translationService;

  @override
  Future<Either<Failure, void>> call(ScheduleNotificationParams params) async {
    try {
      // Check if notifications are enabled
      final enabledResult = await _notificationRepository.getNotificationsEnabled();
      if (enabledResult.isLeft()) {
        return enabledResult.fold((f) => Left(f), (_) => const Right(null));
      }
      final enabled = enabledResult.getOrElse(() => false);
      if (!enabled) {
        return const Right(null); // Notifications disabled, nothing to do
      }

      // Get notification time
      final timeResult = await _notificationRepository.getNotificationTime();
      if (timeResult.isLeft()) {
        return timeResult.fold((f) => Left(f), (_) => const Right(null));
      }
      final (hour, minute) = timeResult.getOrElse(() => (8, 0));

      // Get today's quote for the notification
      final Quote quote;
      if (params.quote != null) {
        quote = params.quote!;
      } else {
        final dayNumber = _getCurrentDayNumber();
        final quoteResult = await _getDailyQuote(
          GetDailyQuoteParams(dayNumber: dayNumber),
        );
        if (quoteResult.isLeft()) {
          return quoteResult.fold((f) => Left(f), (_) => const Right(null));
        }
        quote = quoteResult.getOrElse(() => throw StateError('unreachable'));
      }

      // Translate the quote text to user's preferred language
      final translatedText = _translationService.getText(quote.id, quote.text);

      // Schedule the notification
      await _notificationService.scheduleDailyNotification(
        quoteText: translatedText,
        author: quote.author,
        hour: hour,
        minute: minute,
      );

      return const Right(null);
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
