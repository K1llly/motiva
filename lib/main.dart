import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection_container.dart' as di;
import 'core/data/quotes_data.dart';
import 'features/quote/data/datasources/quote_local_datasource.dart';
import 'features/quote/data/models/quote_model.dart';
import 'features/home_widget/domain/usecases/update_widget_data.dart';
import 'features/quote/domain/usecases/get_daily_quote.dart';
import 'features/notifications/presentation/services/notification_service.dart';
import 'features/notifications/domain/usecases/schedule_daily_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Initialize quotes if first launch
  await _initializeQuotes();

  // Initialize widget with current quote
  await _initializeWidget();

  // Initialize notifications
  await _initializeNotifications();

  runApp(const MotivaApp());
}

Future<void> _initializeQuotes() async {
  final quoteDataSource = di.sl<QuoteLocalDataSource>();
  final hasQuotes = await quoteDataSource.hasQuotes();

  if (!hasQuotes) {
    final quotes = stoicQuotes.map((q) => QuoteModel.fromJson(q)).toList();
    await quoteDataSource.initializeQuotes(quotes);
  }
}

/// Initialize widget with current daily quote data
/// This ensures the widget shows content even before the app is fully opened
Future<void> _initializeWidget() async {
  try {
    final dateUtilsService = di.sl<di.DateUtilsService>();
    final getDailyQuote = di.sl<GetDailyQuote>();
    final updateWidgetData = di.sl<UpdateWidgetData>();

    final dayNumber = dateUtilsService.getCurrentDayNumber();
    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));

    await quoteResult.fold(
      (failure) async {
        // If we fail to get the quote, don't crash - widget will show default
        debugPrint('Failed to initialize widget: ${failure.message}');
      },
      (quote) async {
        await updateWidgetData(UpdateWidgetParams(
          quoteText: quote.text,
          author: quote.author,
          dayNumber: dayNumber,
        ));
      },
    );
  } catch (e) {
    // Widget initialization is not critical - app should still run
    debugPrint('Widget initialization error: $e');
  }
}

/// Initialize notifications and schedule daily quote notification
Future<void> _initializeNotifications() async {
  try {
    final notificationService = di.sl<NotificationService>();
    final scheduleDailyNotification = di.sl<ScheduleDailyNotification>();
    final dateUtilsService = di.sl<di.DateUtilsService>();
    final getDailyQuote = di.sl<GetDailyQuote>();

    // Initialize the notification service
    await notificationService.initialize();

    // Request notification permissions
    await notificationService.requestPermissions();

    // Try to schedule daily notification
    try {
      await scheduleDailyNotification(const ScheduleNotificationParams());
    } catch (e) {
      debugPrint('Could not schedule daily notification: $e');
    }

    // Show an immediate notification with today's quote (for testing)
    final dayNumber = dateUtilsService.getCurrentDayNumber();
    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));
    quoteResult.fold(
      (failure) => debugPrint('Failed to get quote for notification: ${failure.message}'),
      (quote) async {
        await notificationService.showNotification(
          quoteText: quote.text,
          author: quote.author,
        );
      },
    );
  } catch (e) {
    // Notification initialization is not critical - app should still run
    debugPrint('Notification initialization error: $e');
  }
}
