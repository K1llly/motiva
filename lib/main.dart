import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'di/injection_container.dart' as di;
import 'core/data/quotes_data.dart';
import 'core/constants/storage_keys.dart';
import 'features/quote/data/datasources/quote_local_datasource.dart';
import 'features/quote/data/models/quote_model.dart';
import 'features/quote/domain/entities/quote.dart';
import 'features/home_widget/data/datasources/widget_datasource.dart';
import 'features/home_widget/domain/usecases/update_widget_data.dart';
import 'features/quote/domain/usecases/get_daily_quote.dart';
import 'features/notifications/presentation/services/notification_service.dart';
import 'features/notifications/domain/usecases/schedule_daily_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent GoogleFonts from making network requests - saves memory
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize dependency injection
  await di.init();

  // Initialize quotes if first launch
  await _initializeQuotes();

  // Load today's quote ONCE and reuse for widget + notifications
  await _initializeWidgetAndNotifications();

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

/// Initialize widget and notifications with a single quote load
Future<void> _initializeWidgetAndNotifications() async {
  try {
    final dateUtilsService = di.sl<di.DateUtilsService>();
    final getDailyQuote = di.sl<GetDailyQuote>();
    final dayNumber = dateUtilsService.getCurrentDayNumber();

    // Load quote ONCE
    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));

    Quote? todayQuote;
    quoteResult.fold(
      (failure) => debugPrint('Failed to get daily quote: ${failure.message}'),
      (quote) => todayQuote = quote,
    );

    // Sync widget data for independent quote calculation
    await _syncWidgetData();

    // Run widget update and notification init (both have internal error handling)
    if (todayQuote != null) {
      await _updateWidget(todayQuote!, dayNumber);
    }
    await _initializeNotifications(todayQuote);
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

/// Sync start date and shuffled order to widget for independent quote calculation
Future<void> _syncWidgetData() async {
  try {
    final prefs = di.sl<SharedPreferences>();
    final quoteDataSource = di.sl<QuoteLocalDataSource>();
    final widgetDataSource = di.sl<WidgetDataSource>();

    // Sync start date (install date)
    final installDateStr = prefs.getString(StorageKeys.installDate);
    if (installDateStr != null) {
      final installDate = DateTime.parse(installDateStr);
      await widgetDataSource.syncStartDate(installDate);
    }

    // Sync shuffled order
    final shuffledOrder = await quoteDataSource.getShuffledOrder();
    await widgetDataSource.syncShuffledOrder(shuffledOrder);
  } catch (e) {
    debugPrint('Widget data sync error: $e');
  }
}

Future<void> _updateWidget(Quote quote, int dayNumber) async {
  try {
    final updateWidgetData = di.sl<UpdateWidgetData>();
    await updateWidgetData(UpdateWidgetParams(
      quoteText: quote.text,
      author: quote.author,
      dayNumber: dayNumber,
    ));
  } catch (e) {
    debugPrint('Widget update error: $e');
  }
}

Future<void> _initializeNotifications(Quote? quote) async {
  try {
    final notificationService = di.sl<NotificationService>();
    final scheduleDailyNotification = di.sl<ScheduleDailyNotification>();

    // Initialize the notification service
    await notificationService.initialize();

    // Request notification permissions
    await notificationService.requestPermissions();

    // Schedule daily notification (skip showing immediate notification to save resources)
    try {
      await scheduleDailyNotification(const ScheduleNotificationParams());
    } catch (e) {
      debugPrint('Could not schedule daily notification: $e');
    }
  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }
}
