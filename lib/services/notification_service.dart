import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _lunchReminderId = 0;
  static const String _lunchReminderChannelId = 'lunch_reminder_channel';
  static const String _lunchReminderChannelName = 'Lunch Reminder';
  static const String _lunchReminderChannelDescription =
      'Channel for lunch reminder notifications';

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _lunchReminderChannelId,
      _lunchReminderChannelName,
      description: _lunchReminderChannelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleLunchReminder() async {
    developer.log(
      '[NotificationService] Scheduling lunch reminder...',
      name: 'Restoreko',
    );
    await _notifications.cancel(_lunchReminderId);

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    developer.log(
      '[NotificationService] Current local time: ${now.toLocal()}\n',
    );

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );

    final localScheduled = scheduledDate.toLocal();
    developer.log(
      '[NotificationService] Scheduled time (local): $localScheduled',
      name: 'Restoreko',
    );

    developer.log(
      '[NotificationService] Original scheduled time: $scheduledDate',
      name: 'Restoreko',
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      final nextDayLocal = scheduledDate.toLocal();
      developer.log(
        '[NotificationService] Adjusted scheduled time (next day): $nextDayLocal',
        name: 'Restoreko',
      );
    }
    final platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        _lunchReminderChannelId,
        _lunchReminderChannelName,
        channelDescription: _lunchReminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    if (kIsWeb) {
      developer.log(
        '[NotificationService] Web platform detected, skipping notification scheduling',
        name: 'Restoreko',
      );
      return;
    }

    developer.log(
      '[NotificationService] Scheduling notification for: $scheduledDate',
      name: 'Restoreko',
    );
    await _notifications.zonedSchedule(
      _lunchReminderId,
      'Waktunya Makan Siang!',
      'Jangan lupa untuk makan siang yang sehat dan bergizi!',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'lunch_reminder',
    );

    developer.log(
      '[NotificationService] Notification scheduled successfully!',
      name: 'Restoreko',
    );
  }

  Future<void> cancelLunchReminder() async {
    await _notifications.cancel(_lunchReminderId);
  }

  Future<bool> isLunchReminderScheduled() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await _notifications.pendingNotificationRequests();

    return pendingNotifications.any(
      (notification) => notification.id == _lunchReminderId,
    );
  }
}
