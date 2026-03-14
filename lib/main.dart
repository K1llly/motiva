import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'di/injection_container.dart' as di;
import 'core/data/quotes_data.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/storage_keys.dart';
import 'core/constants/widget_constants.dart';
import 'features/quote/data/datasources/quote_local_datasource.dart';
import 'features/quote/data/datasources/quote_local_datasource_impl.dart';
import 'features/quote/data/models/quote_model.dart';
import 'features/quote/domain/entities/quote.dart';
import 'features/home_widget/data/datasources/widget_datasource.dart';
import 'features/home_widget/domain/usecases/update_widget_data.dart';
import 'features/quote/domain/usecases/get_daily_quote.dart';
import 'features/notifications/presentation/services/notification_service.dart';
import 'features/notifications/domain/usecases/schedule_daily_notification.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'core/services/quote_translation_service.dart';
import 'core/constants/app_constants.dart' show AppConstants;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent GoogleFonts from making network requests - saves memory
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize dependency injection
  await di.init();

  // Set app group ID once for all HomeWidget operations (avoid repeated platform calls)
  await HomeWidget.setAppGroupId(WidgetConstants.appGroupId);

  // Initialize quotes if first launch
  await _initializeQuotes();

  // Initialize widget data (fast, needed before first frame)
  await _initializeWidget();

  runApp(const MotivaApp());

  // Defer notification initialization to after first frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeNotificationsDeferred();
  });
}

Future<void> _initializeQuotes() async {
  final quoteDataSource = di.sl<QuoteLocalDataSource>();
  final prefs = di.sl<SharedPreferences>();
  final hasQuotes = await quoteDataSource.hasQuotes();

  if (!hasQuotes) {
    // First launch: load all quotes
    final quotes = stoicQuotes.map((q) => QuoteModel.fromJson(q)).toList();
    await quoteDataSource.initializeQuotes(quotes);
  } else {
    // Existing user: check if quotes need updating (e.g. 30 -> 1000)
    final savedVersion = prefs.getInt(StorageKeys.quotesVersion) ?? 1;
    if (savedVersion < AppConstants.quotesVersion) {
      final quotes = stoicQuotes.map((q) => QuoteModel.fromJson(q)).toList();
      await quoteDataSource.initializeQuotes(quotes);
      // Clean up legacy shuffled order
      await prefs.remove(StorageKeys.shuffledQuoteOrder);
      await prefs.setInt(StorageKeys.quotesVersion, AppConstants.quotesVersion);
    }
  }

  // Ensure quotes version is saved for new installs too
  if (!prefs.containsKey(StorageKeys.quotesVersion)) {
    await prefs.setInt(StorageKeys.quotesVersion, AppConstants.quotesVersion);
  }
}

/// Initialize widget data (runs before first frame)
Future<void> _initializeWidget() async {
  try {
    // Load user's preferred locale BEFORE updating widget text
    final settingsRepo = di.sl<SettingsRepository>();
    final translationService = di.sl<QuoteTranslationService>();
    final locale = await settingsRepo.getSelectedLocale();
    if (locale != null) {
      await translationService.loadLocale(locale.languageCode);
    }

    final dateUtilsService = di.sl<di.DateUtilsService>();
    final getDailyQuote = di.sl<GetDailyQuote>();
    final dayNumber = dateUtilsService.getCurrentDayNumber();

    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));

    // Sync widget data for independent quote calculation
    await _syncWidgetData();

    quoteResult.fold(
      (failure) => debugPrint('Failed to get daily quote: ${failure.message}'),
      (quote) async {
        await _updateWidget(quote, dayNumber);
      },
    );
  } catch (e) {
    debugPrint('Widget initialization error: $e');
  }
}

/// Initialize notifications (deferred to after first frame)
Future<void> _initializeNotificationsDeferred() async {
  try {
    final getDailyQuote = di.sl<GetDailyQuote>();
    final dateUtilsService = di.sl<di.DateUtilsService>();
    final dayNumber = dateUtilsService.getCurrentDayNumber();
    final quoteResult = await getDailyQuote(GetDailyQuoteParams(dayNumber: dayNumber));

    Quote? todayQuote;
    quoteResult.fold(
      (failure) => null,
      (quote) => todayQuote = quote,
    );

    await _initializeNotifications(todayQuote);
  } catch (e) {
    debugPrint('Deferred notification init error: $e');
  }
}

/// Sync user seed to widget for independent quote calculation
Future<void> _syncWidgetData() async {
  try {
    final quoteDataSource = di.sl<QuoteLocalDataSource>();
    final widgetDataSource = di.sl<WidgetDataSource>();

    // Sync user seed so the widget can independently pick the same daily quote
    if (quoteDataSource is QuoteLocalDataSourceImpl) {
      final userSeed = await quoteDataSource.getUserSeed();
      await widgetDataSource.syncUserSeed(userSeed);
    }
  } catch (e) {
    debugPrint('Widget data sync error: $e');
  }
}

Future<void> _updateWidget(Quote quote, int dayNumber) async {
  try {
    final updateWidgetData = di.sl<UpdateWidgetData>();
    final translationService = di.sl<QuoteTranslationService>();
    final translatedText = translationService.getText(quote.id, quote.text);

    await updateWidgetData(UpdateWidgetParams(
      quoteText: translatedText,
      author: quote.author,
      dayNumber: dayNumber,
    ));

    // Pre-cache translated quotes for the next 7 days so the widget
    // can update automatically at midnight without needing the app to run
    await _preCacheTranslatedQuotes();
  } catch (e) {
    debugPrint('Widget update error: $e');
  }
}

/// Pre-compute and store translated quotes for the next 7 days in shared storage.
/// The iOS widget reads this cache to show translated quotes when the app hasn't run.
Future<void> _preCacheTranslatedQuotes() async {
  try {
    final translationService = di.sl<QuoteTranslationService>();
    final quoteDataSource = di.sl<QuoteLocalDataSource>();
    final widgetDataSource = di.sl<WidgetDataSource>();

    // Get user seed for deterministic quote selection
    int userSeed = 0;
    if (quoteDataSource is QuoteLocalDataSourceImpl) {
      userSeed = await quoteDataSource.getUserSeed();
    }

    final cache = <String, Map<String, String>>{};
    final now = DateTime.now();

    for (int i = 0; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      final dateKey = date.year * 10000 + date.month * 100 + date.day;
      final combined = dateKey ^ userSeed;
      final quoteIndex = (combined.abs() % AppConstants.totalQuotes) + 1;
      final quoteId = 'q${quoteIndex.toString().padLeft(3, '0')}';

      try {
        final quote = await quoteDataSource.getQuoteById(quoteId);
        final translatedText = translationService.getText(quote.id, quote.text);
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        cache[dateStr] = {
          'text': translatedText,
          'author': quote.author,
        };
      } catch (_) {
        // Skip if quote not found
      }
    }

    await widgetDataSource.saveTranslatedCache(json.encode(cache));
  } catch (e) {
    debugPrint('Pre-cache translated quotes error: $e');
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

    // Schedule daily notification
    try {
      await scheduleDailyNotification(const ScheduleNotificationParams());
    } catch (e) {
      debugPrint('Could not schedule daily notification: $e');
    }

  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }
}
