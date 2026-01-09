import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/utils/date_utils.dart';
import '../core/constants/storage_keys.dart';

// Quote Feature
import '../features/quote/domain/repositories/quote_repository.dart';
import '../features/quote/domain/usecases/get_daily_quote.dart';
import '../features/quote/domain/usecases/get_all_quotes.dart';
import '../features/quote/domain/usecases/get_quote_meaning.dart';
import '../features/quote/data/datasources/quote_local_datasource.dart';
import '../features/quote/data/datasources/quote_local_datasource_impl.dart';
import '../features/quote/data/repositories/quote_repository_impl.dart';
import '../features/quote/presentation/bloc/quote_bloc.dart';

// Streak Feature
import '../features/streak/domain/repositories/streak_repository.dart';
import '../features/streak/domain/usecases/get_current_streak.dart';
import '../features/streak/domain/usecases/increment_streak.dart';
import '../features/streak/domain/usecases/reset_streak.dart';
import '../features/streak/data/datasources/streak_local_datasource.dart';
import '../features/streak/data/repositories/streak_repository_impl.dart';
import '../features/streak/presentation/bloc/streak_bloc.dart';

// Sharing Feature
import '../features/sharing/domain/repositories/share_repository.dart';
import '../features/sharing/domain/usecases/share_to_instagram.dart';
import '../features/sharing/domain/usecases/share_to_twitter.dart';
import '../features/sharing/domain/usecases/share_to_whatsapp.dart';
import '../features/sharing/data/services/share_service.dart';
import '../features/sharing/data/repositories/share_repository_impl.dart';

// Widget Feature
import '../features/home_widget/domain/repositories/widget_repository.dart';
import '../features/home_widget/domain/repositories/widget_settings_repository.dart';
import '../features/home_widget/domain/usecases/update_widget_data.dart';
import '../features/home_widget/domain/usecases/sync_widget_quote.dart';
import '../features/home_widget/domain/usecases/get_widget_settings.dart';
import '../features/home_widget/domain/usecases/update_widget_appearance.dart';
import '../features/home_widget/data/datasources/widget_datasource.dart';
import '../features/home_widget/data/datasources/widget_settings_datasource.dart';
import '../features/home_widget/data/repositories/widget_repository_impl.dart';
import '../features/home_widget/data/repositories/widget_settings_repository_impl.dart';
import '../features/home_widget/presentation/bloc/widget_settings_bloc.dart';

// Notification Feature
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/schedule_daily_notification.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/presentation/services/notification_service.dart';

// Settings Feature
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await _initExternal();

  //! Core
  _initCore();

  //! Features
  _initQuoteFeature();
  _initStreakFeature();
  _initSharingFeature();
  _initWidgetFeature();
  _initNotificationFeature();
  _initSettingsFeature();
}

Future<void> _initExternal() async {
  // Hive
  await Hive.initFlutter();
  final quoteBox = await Hive.openBox<Map>(StorageKeys.quotesBox);
  final streakBox = await Hive.openBox<Map>(StorageKeys.streakBox);
  final userDataBox = await Hive.openBox<Map>(StorageKeys.userDataBox);

  sl.registerLazySingleton<Box<Map>>(() => quoteBox, instanceName: 'quoteBox');
  sl.registerLazySingleton<Box<Map>>(() => streakBox,
      instanceName: 'streakBox');
  sl.registerLazySingleton<Box<Map>>(() => userDataBox,
      instanceName: 'userDataBox');

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
}

void _initCore() {
  // Date utilities service
  sl.registerLazySingleton<DateUtilsService>(
    () => DateUtilsServiceImpl(prefs: sl()),
  );
}

void _initQuoteFeature() {
  // BLoC
  sl.registerFactory(
    () => QuoteBloc(
      getDailyQuote: sl(),
      incrementStreak: sl(),
      updateWidgetData: sl(),
      getCurrentDayNumber: () => sl<DateUtilsService>().getCurrentDayNumber(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDailyQuote(sl()));
  sl.registerLazySingleton(() => GetAllQuotes(sl()));
  sl.registerLazySingleton(() => GetQuoteMeaning(sl()));

  // Repository
  sl.registerLazySingleton<QuoteRepository>(
    () => QuoteRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<QuoteLocalDataSource>(
    () => QuoteLocalDataSourceImpl(
      quoteBox: sl<Box<Map>>(instanceName: 'quoteBox'),
      prefs: sl(),
    ),
  );
}

void _initStreakFeature() {
  // BLoC
  sl.registerFactory(
    () => StreakBloc(
      getCurrentStreak: sl(),
      incrementStreak: sl(),
      resetStreak: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentStreak(sl()));
  sl.registerLazySingleton(() => IncrementStreak(sl()));
  sl.registerLazySingleton(() => ResetStreak(sl()));

  // Repository
  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<StreakLocalDataSource>(
    () => StreakLocalDataSourceImpl(
      streakBox: sl<Box<Map>>(instanceName: 'streakBox'),
    ),
  );
}

void _initSharingFeature() {
  // Use Cases
  sl.registerLazySingleton(() => ShareToInstagram(sl()));
  sl.registerLazySingleton(() => ShareToTwitter(sl()));
  sl.registerLazySingleton(() => ShareToWhatsApp(sl()));

  // Repository
  sl.registerLazySingleton<ShareRepository>(
    () => ShareRepositoryImpl(shareService: sl()),
  );

  // Services
  sl.registerLazySingleton(() => ShareService());
}

void _initWidgetFeature() {
  // BLoC
  sl.registerFactory(
    () => WidgetSettingsBloc(
      getWidgetSettings: sl(),
      updateWidgetAppearance: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => UpdateWidgetData(sl()));
  sl.registerLazySingleton(() => SyncWidgetQuote(sl()));
  sl.registerLazySingleton(() => GetWidgetSettings(sl()));
  sl.registerLazySingleton(() => UpdateWidgetAppearance(
        settingsRepository: sl(),
        widgetRepository: sl(),
      ));

  // Repository
  sl.registerLazySingleton<WidgetRepository>(
    () => WidgetRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<WidgetSettingsRepository>(
    () => WidgetSettingsRepositoryImpl(dataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<WidgetDataSource>(
    () => WidgetDataSourceImpl(),
  );
  sl.registerLazySingleton<WidgetSettingsDataSource>(
    () => WidgetSettingsDataSourceImpl(),
  );
}

void _initNotificationFeature() {
  // Service
  sl.registerLazySingleton(() => NotificationService());

  // Use Cases
  sl.registerLazySingleton(
    () => ScheduleDailyNotification(
      notificationService: sl(),
      notificationRepository: sl(),
      getDailyQuote: sl(),
      getCurrentDayNumber: () => sl<DateUtilsService>().getCurrentDayNumber(),
    ),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
}

void _initSettingsFeature() {
  // BLoC
  sl.registerFactory(
    () => SettingsBloc(sl()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
}

/// Date utilities service interface
abstract class DateUtilsService {
  int getCurrentDayNumber();
}

/// Date utilities service implementation
class DateUtilsServiceImpl implements DateUtilsService {
  final SharedPreferences prefs;

  // TESTING: Change this value to simulate different days (0 = today, 1 = tomorrow, etc.)
  // Set back to 0 for production
  static const int testDayOffset = 0;

  DateUtilsServiceImpl({required this.prefs});

  @override
  int getCurrentDayNumber() {
    final installDateStr = prefs.getString(StorageKeys.installDate);
    if (installDateStr == null) {
      // First launch - set install date
      final now = DateTime.now();
      prefs.setString(StorageKeys.installDate, now.toIso8601String());
      return 1 + testDayOffset;
    }
    final installDate = DateTime.parse(installDateStr);
    return AppDateUtils.calculateDayNumber(installDate) + testDayOffset;
  }
}
