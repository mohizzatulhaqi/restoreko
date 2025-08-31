import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'restaurant_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      developer.log(
        '[BackgroundService] Task started: $task',
        name: 'Restoreko',
      );

      final notificationService = NotificationService();
      await notificationService.initialize();

      final prefs = await SharedPreferences.getInstance();
      final isRecommendationEnabled =
          prefs.getBool('restaurant_recommendation_enabled') ?? false;

      if (!isRecommendationEnabled) {
        developer.log(
          '[BackgroundService] Restaurant recommendations are disabled, skipping...',
          name: 'Restoreko',
        );
        return true;
      }

      developer.log(
        '[BackgroundService] Getting random restaurant...',
        name: 'Restoreko',
      );
      final restaurantService = RestaurantService();
      final restaurant = await restaurantService.getRandomRestaurant();

      developer.log(
        '[BackgroundService] Showing notification for restaurant: ${restaurant.name}',
        name: 'Restoreko',
      );

      await notificationService.showRandomRestaurantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
        title: 'Rekomendasi Restoran',
        body: 'Coba restoran ${restaurant.name} di ${restaurant.city}',
      );

      developer.log(
        '[BackgroundService] Task completed successfully',
        name: 'Restoreko',
      );
      return true;
    } catch (e) {
      developer.log('Error in background task: $e', name: 'BackgroundService');
      return false;
    }
  });
}

class BackgroundService {
  static const String dailyTask = 'dailyRestaurantRecommendation';

  static Future<void> initialize() async {
    try {
      developer.log(
        '[BackgroundService] Initializing Workmanager...',
        name: 'Restoreko',
      );

      await Workmanager().cancelAll();

      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

      developer.log(
        '[BackgroundService] Workmanager initialized successfully',
        name: 'Restoreko',
      );

      developer.log(
        '[BackgroundService] Workmanager initialization completed',
        name: 'Restoreko',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[BackgroundService] Error initializing Workmanager: $e',
        name: 'Restoreko',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<void> scheduleDailyNotification() async {
    try {
      developer.log(
        '[BackgroundService] Starting to schedule daily notification...',
        name: 'Restoreko',
      );

      await Workmanager().cancelAll();

      await Future.delayed(const Duration(seconds: 1));

      developer.log(
        '[BackgroundService] Cancelled any existing tasks',
        name: 'Restoreko',
      );

      final initialDelay = _calculateInitialDelay();
      developer.log(
        '[BackgroundService] Initial delay: ${initialDelay.inHours}h ${initialDelay.inMinutes.remainder(60)}m',
        name: 'Restoreko',
      );

      try {
        await Workmanager().registerPeriodicTask(
          dailyTask,
          dailyTask,
          frequency: const Duration(hours: 24),
          initialDelay: initialDelay,
          constraints: Constraints(
            networkType: NetworkType.connected,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false,
          ),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          backoffPolicy: BackoffPolicy.linear,
          backoffPolicyDelay: const Duration(minutes: 5),
        );

        developer.log(
          '[BackgroundService] Successfully registered periodic task',
          name: 'Restoreko',
        );
      } catch (e) {
        developer.log(
          '[BackgroundService] Error in registerPeriodicTask: $e',
          name: 'Restoreko',
          error: e,
        );
        await Workmanager().registerPeriodicTask(
          '${dailyTask}_retry',
          dailyTask,
          frequency: const Duration(hours: 24),
          initialDelay: initialDelay,
        );
      }

      final now = tz.TZDateTime.now(tz.local);
      final nextRun = now.add(initialDelay);
      developer.log(
        '[BackgroundService] Next notification scheduled for: $nextRun',
        name: 'Restoreko',
      );

      developer.log(
        '[BackgroundService] Daily notification scheduling completed',
        name: 'Restoreko',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[BackgroundService] Critical error in scheduleDailyNotification: $e',
        name: 'Restoreko',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Duration _calculateInitialDelay() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      18,
      0,
    );

    developer.log('[BackgroundService] Current time: $now', name: 'Restoreko');

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
      developer.log(
        '[BackgroundService] Scheduled time is in the past, moving to tomorrow: $scheduledTime',
        name: 'Restoreko',
      );
    } else {
      developer.log(
        '[BackgroundService] Next notification scheduled for: $scheduledTime',
        name: 'Restoreko',
      );
    }

    final delay = scheduledTime.difference(now);
    developer.log(
      '[BackgroundService] Time until next notification: ${delay.inHours}h ${delay.inMinutes.remainder(60)}m',
      name: 'Restoreko',
    );

    return delay;
  }

  static Future<void> cancelDailyNotification() async {
    try {
      developer.log(
        '[BackgroundService] Starting to cancel all scheduled notifications...',
        name: 'Restoreko',
      );

      await Workmanager().cancelAll();

      developer.log(
        '[BackgroundService] Successfully cancelled all scheduled notifications',
        name: 'Restoreko',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[BackgroundService] Error cancelling notifications: $e',
        name: 'Restoreko',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
