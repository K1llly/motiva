import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:stoic_mind/core/constants/notification_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  static bool _timezonesInitialized = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    if (!_timezonesInitialized) {
      tz_data.initializeTimeZones();
      // Set local timezone based on device's UTC offset
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final locations = tz.timeZoneDatabase.locations;
      for (final loc in locations.values) {
        if (loc.currentTimeZone.offset == offset.inMilliseconds) {
          tz.setLocalLocation(loc);
          break;
        }
      }
      _timezonesInitialized = true;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createNotificationChannel();
  }

  /// Request notification permissions (skips if already granted)
  Future<bool> requestPermissions() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iOS = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      // Check if already granted to avoid redundant native calls
      final areEnabled = await android.areNotificationsEnabled();
      if (areEnabled == true) return true;

      // Request notification permission
      final notificationGranted = await android.requestNotificationsPermission();

      return notificationGranted ?? false;
    }

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Build notification details with consistent settings
  NotificationDetails _buildNotificationDetails(String body, String author) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        channelDescription: NotificationConstants.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: '<b>${NotificationConstants.notificationTitle}</b>',
          htmlFormatContentTitle: true,
          summaryText: author,
          htmlFormatSummaryText: true,
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Schedule daily notification at specified time
  Future<void> scheduleDailyNotification({
    required String quoteText,
    required String author,
    required int hour,
    required int minute,
  }) async {
    final body = NotificationConstants.formatBody(quoteText, author);

    await _notificationsPlugin.zonedSchedule(
      NotificationConstants.dailyQuoteNotificationId,
      NotificationConstants.notificationTitle,
      body,
      _nextInstanceOfTime(hour, minute),
      _buildNotificationDetails(body, author),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Show immediate notification (for testing)
  Future<void> showNotification({
    required String quoteText,
    required String author,
  }) async {
    final body = NotificationConstants.formatBody(quoteText, author);

    await _notificationsPlugin.show(
      NotificationConstants.dailyQuoteNotificationId,
      NotificationConstants.notificationTitle,
      body,
      _buildNotificationDetails(body, author),
    );
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationConstants.channelId,
          NotificationConstants.channelName,
          description: NotificationConstants.channelDescription,
          importance: Importance.high,
        ),
      );
    }
  }

  /// Calculate next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // App will open automatically when notification is tapped
    // Additional navigation logic can be added here if needed
  }
}
