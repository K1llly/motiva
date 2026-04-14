import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:stoic_mind/core/constants/notification_constants.dart';
import 'package:stoic_mind/core/errors/failures.dart';
import 'package:stoic_mind/core/services/quote_translation_service.dart';
import 'package:stoic_mind/core/usecases/usecase.dart';
import 'package:stoic_mind/features/notifications/domain/repositories/notification_repository.dart';
import 'package:stoic_mind/features/notifications/presentation/services/notification_service.dart';
import 'package:stoic_mind/features/quote/domain/repositories/quote_repository.dart';

class ScheduleDailyNotification implements UseCase<void, ScheduleNotificationParams> {
  final NotificationService _notificationService;
  final NotificationRepository _notificationRepository;
  final QuoteRepository _quoteRepository;
  final QuoteTranslationService _translationService;

  ScheduleDailyNotification({
    required NotificationService notificationService,
    required NotificationRepository notificationRepository,
    required QuoteRepository quoteRepository,
    required QuoteTranslationService translationService,
  })  : _notificationService = notificationService,
        _notificationRepository = notificationRepository,
        _quoteRepository = quoteRepository,
        _translationService = translationService;

  @override
  Future<Either<Failure, void>> call(ScheduleNotificationParams params) async {
    try {
      final enabledResult = await _notificationRepository.getNotificationsEnabled();
      if (enabledResult.isLeft()) {
        return enabledResult.fold((f) => Left(f), (_) => const Right(null));
      }
      final enabled = enabledResult.getOrElse(() => false);
      if (!enabled) {
        // User turned notifications off — drop anything still queued.
        await _notificationService.scheduleUpcomingDailyNotifications(
          entries: const [],
          hour: 0,
          minute: 0,
        );
        return const Right(null);
      }

      final timeResult = await _notificationRepository.getNotificationTime();
      if (timeResult.isLeft()) {
        return timeResult.fold((f) => Left(f), (_) => const Right(null));
      }
      final (hour, minute) = timeResult.getOrElse(() => (
            NotificationConstants.defaultHour,
            NotificationConstants.defaultMinute,
          ));

      // Build the next N days of notification entries, each with that day's
      // own quote translated to the user's current language.
      final today = DateTime.now();
      final entries = <UpcomingDailyQuote>[];
      for (int i = 0; i < NotificationConstants.upcomingDays; i++) {
        final date = DateTime(today.year, today.month, today.day)
            .add(Duration(days: i));
        final quoteResult = await _quoteRepository.getQuoteForDate(date);
        final quote = quoteResult.fold((_) => null, (q) => q);
        if (quote == null) continue;
        final translatedText = _translationService.getText(quote.id, quote.text);
        entries.add(UpcomingDailyQuote(
          date: date,
          dayOffset: i,
          text: translatedText,
          author: quote.author,
        ));
      }

      await _notificationService.scheduleUpcomingDailyNotifications(
        entries: entries,
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
  const ScheduleNotificationParams();

  @override
  List<Object?> get props => const [];
}

/// Failure specific to notification operations
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}
