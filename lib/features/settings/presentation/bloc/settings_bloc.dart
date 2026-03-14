import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/services/quote_translation_service.dart';
import '../../../quote/domain/usecases/get_daily_quote.dart';
import '../../../home_widget/domain/usecases/update_widget_data.dart';
import '../../../notifications/domain/repositories/notification_repository.dart';
import '../../../notifications/domain/usecases/schedule_daily_notification.dart';
import '../../../notifications/presentation/services/notification_service.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  final QuoteTranslationService _translationService;
  final GetDailyQuote _getDailyQuote;
  final UpdateWidgetData _updateWidgetData;
  final int Function() _getCurrentDayNumber;
  final NotificationRepository _notificationRepository;
  final NotificationService _notificationService;
  final ScheduleDailyNotification _scheduleDailyNotification;

  SettingsBloc(
    this._repository,
    this._translationService, {
    required GetDailyQuote getDailyQuote,
    required UpdateWidgetData updateWidgetData,
    required int Function() getCurrentDayNumber,
    required NotificationRepository notificationRepository,
    required NotificationService notificationService,
    required ScheduleDailyNotification scheduleDailyNotification,
  })  : _getDailyQuote = getDailyQuote,
        _updateWidgetData = updateWidgetData,
        _getCurrentDayNumber = getCurrentDayNumber,
        _notificationRepository = notificationRepository,
        _notificationService = notificationService,
        _scheduleDailyNotification = scheduleDailyNotification,
        super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeLanguageEvent>(
      _onChangeLanguage,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
    on<ChangeThemeModeEvent>(_onChangeThemeMode);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ChangeNotificationTimeEvent>(_onChangeNotificationTime);
    on<ChangeAppFontEvent>(_onChangeAppFont);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final locale = await _repository.getSelectedLocale();
      if (locale != null) {
        await _translationService.loadLocale(locale.languageCode);
      }

      final themeMode = await _repository.getThemeMode();

      final enabledResult = await _notificationRepository.getNotificationsEnabled();
      final notificationsEnabled = enabledResult.getOrElse(() => true);

      final timeResult = await _notificationRepository.getNotificationTime();
      final (hour, minute) = timeResult.getOrElse(() => (7, 0));

      final appFontKey = await _repository.getAppFont();

      emit(SettingsLoaded(
        locale: locale,
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        notificationHour: hour,
        notificationMinute: minute,
        appFontKey: appFontKey,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      await _translationService.loadLocale(event.locale.languageCode);
      await _repository.saveSelectedLocale(event.locale);
      await _updateWidgetWithTranslation();
      // Re-schedule notification with translated text
      await _scheduleDailyNotification(const ScheduleNotificationParams());
      emit(current.copyWith(locale: event.locale));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      await _repository.saveThemeMode(event.themeMode);
      emit(current.copyWith(themeMode: event.themeMode));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      await _notificationRepository.setNotificationsEnabled(event.enabled);

      if (event.enabled) {
        await _scheduleDailyNotification(const ScheduleNotificationParams());
      } else {
        await _notificationService.cancelAllNotifications();
      }

      emit(current.copyWith(notificationsEnabled: event.enabled));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeNotificationTime(
    ChangeNotificationTimeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      await _notificationRepository.setNotificationTime(event.hour, event.minute);

      if (current.notificationsEnabled) {
        await _scheduleDailyNotification(const ScheduleNotificationParams());
      }

      emit(current.copyWith(
        notificationHour: event.hour,
        notificationMinute: event.minute,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onChangeAppFont(
    ChangeAppFontEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state;
    if (current is! SettingsLoaded) return;

    try {
      await _repository.saveAppFont(event.fontKey);
      emit(current.copyWith(appFontKey: event.fontKey));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _updateWidgetWithTranslation() async {
    try {
      final dayNumber = _getCurrentDayNumber();
      final result = await _getDailyQuote(
        GetDailyQuoteParams(dayNumber: dayNumber),
      );
      result.fold(
        (_) {},
        (quote) async {
          final translatedText =
              _translationService.getText(quote.id, quote.text);
          await _updateWidgetData(UpdateWidgetParams(
            quoteText: translatedText,
            author: quote.author,
            dayNumber: dayNumber,
          ));
        },
      );
    } catch (_) {}
  }
}
