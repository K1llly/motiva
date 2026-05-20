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

  /// Schedule the next N daily notifications, one per day, each carrying
  /// that day's actual quote. We do NOT use [DateTimeComponents.time] —
  /// that would freeze a single payload and replay it forever, causing
  /// the "yesterday's quote" bug. Instead the app re-runs this on every
  /// launch / settings change to keep the queue current.
  Future<void> scheduleUpcomingDailyNotifications({
    required List<UpcomingDailyQuote> entries,
    required int hour,
    required int minute,
  }) async {
    // Cancel every pending notification before rescheduling. cancelAll wipes
    // the v1.2 queue (ids 1000..1029) plus the legacy v1.1 repeating entry
    // (id 1, DateTimeComponents.time), which upgraders still have pending and
    // would otherwise fire alongside the new queue with a frozen old quote.
    await _notificationsPlugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);

    for (final entry in entries) {
      final scheduled = tz.TZDateTime(
        tz.local,
        entry.date.year,
        entry.date.month,
        entry.date.day,
        hour,
        minute,
      );

      // Today's slot may already be in the past — skip it.
      if (!scheduled.isAfter(now)) continue;

      final body = NotificationConstants.formatBody(entry.text, entry.author);

      await _notificationsPlugin.zonedSchedule(
        NotificationConstants.dailyQuoteIdBase + entry.dayOffset,
        NotificationConstants.notificationTitle,
        body,
        scheduled,
        _buildNotificationDetails(body, entry.author),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
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

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // App will open automatically when notification is tapped
    // Additional navigation logic can be added here if needed
  }
}

/// One day's worth of scheduling input for [NotificationService].
class UpcomingDailyQuote {
  final DateTime date;
  final int dayOffset;
  final String text;
  final String author;

  const UpcomingDailyQuote({
    required this.date,
    required this.dayOffset,
    required this.text,
    required this.author,
  });
}
