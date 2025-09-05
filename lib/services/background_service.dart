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
  static bool _isInitialized = false;
  static bool _initializationFailed = false;

  static bool get isInitialized => _isInitialized;
  static bool get initializationFailed => _initializationFailed;

  /// Initialize WorkManager with retry logic and better error handling
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log(
        '[BackgroundService] Already initialized, skipping...',
        name: 'Restoreko',
      );
      return;
    }

    if (_initializationFailed) {
      developer.log(
        '[BackgroundService] Previous initialization failed, not retrying',
        name: 'Restoreko',
      );
      throw Exception('BackgroundService initialization previously failed');
    }

    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries && !_isInitialized) {
      try {
        retryCount++;
        developer.log(
          '[BackgroundService] Initializing Workmanager... (attempt $retryCount/$maxRetries)',
          name: 'Restoreko',
        );

        // Add progressive delay between retries
        if (retryCount > 1) {
          final delayMs = 300 * retryCount; // 300ms, 600ms, 900ms
          developer.log(
            '[BackgroundService] Waiting ${delayMs}ms before retry...',
            name: 'Restoreko',
          );
          await Future.delayed(Duration(milliseconds: delayMs));
        }

        // Try to safely cancel existing work first
        await _safeCancelAll(retryCount == 1);

        // Initialize with a small delay to ensure platform channels are ready
        await Future.delayed(const Duration(milliseconds: 100));

        await Workmanager().initialize(
            callbackDispatcher,
            isInDebugMode: false
        );

        _isInitialized = true;
        developer.log(
          '[BackgroundService] Workmanager initialized successfully on attempt $retryCount',
          name: 'Restoreko',
        );

        break; // Exit retry loop on success

      } catch (e, stackTrace) {
        developer.log(
          '[BackgroundService] Initialization attempt $retryCount failed: $e',
          name: 'Restoreko',
          error: e,
        );

        if (retryCount >= maxRetries) {
          _initializationFailed = true;
          developer.log(
            '[BackgroundService] All initialization attempts failed. WorkManager will be disabled.',
            name: 'Restoreko',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        }
      }
    }

    developer.log(
      '[BackgroundService] Workmanager initialization completed',
      name: 'Restoreko',
    );
  }

  /// Safely attempt to cancel all work with error handling
  static Future<void> _safeCancelAll(bool logErrors) async {
    try {
      await Workmanager().cancelAll();
      if (logErrors) {
        developer.log(
          '[BackgroundService] Successfully cancelled existing work',
          name: 'Restoreko',
        );
      }
    } catch (e) {
      if (logErrors) {
        developer.log(
          '[BackgroundService] Could not cancel existing work (might be expected): $e',
          name: 'Restoreko',
        );
      }
      // Don't rethrow - this is expected in some cases
    }
  }

  static Future<void> scheduleDailyNotification() async {
    if (!_isInitialized) {
      developer.log(
        '[BackgroundService] Cannot schedule notification: WorkManager not initialized',
        name: 'Restoreko',
      );
      return;
    }

    if (_initializationFailed) {
      developer.log(
        '[BackgroundService] Cannot schedule notification: WorkManager initialization failed',
        name: 'Restoreko',
      );
      return;
    }

    try {
      developer.log(
        '[BackgroundService] Starting to schedule daily notification...',
        name: 'Restoreko',
      );

      // Safe cancel with error handling
      await _safeCancelAll(true);
      await Future.delayed(const Duration(milliseconds: 500));

      final initialDelay = _calculateInitialDelay();
      developer.log(
        '[BackgroundService] Initial delay: ${initialDelay.inHours}h ${initialDelay.inMinutes.remainder(60)}m',
        name: 'Restoreko',
      );

      // Primary registration attempt
      bool registrationSucceeded = false;
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

        registrationSucceeded = true;
        developer.log(
          '[BackgroundService] Successfully registered periodic task',
          name: 'Restoreko',
        );

      } catch (e) {
        developer.log(
          '[BackgroundService] Primary registration failed: $e',
          name: 'Restoreko',
          error: e,
        );

        // Fallback: Try with simpler configuration
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          await Workmanager().registerPeriodicTask(
            '${dailyTask}_simple',
            dailyTask,
            frequency: const Duration(hours: 24),
            initialDelay: initialDelay,
            existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
          );

          registrationSucceeded = true;
          developer.log(
            '[BackgroundService] Fallback registration succeeded',
            name: 'Restoreko',
          );
        } catch (fallbackError) {
          developer.log(
            '[BackgroundService] Fallback registration also failed: $fallbackError',
            name: 'Restoreko',
            error: fallbackError,
          );
        }
      }

      if (registrationSucceeded) {
        final now = tz.TZDateTime.now(tz.local);
        final nextRun = now.add(initialDelay);
        developer.log(
          '[BackgroundService] Next notification scheduled for: $nextRun',
          name: 'Restoreko',
        );
      }

      developer.log(
        '[BackgroundService] Daily notification scheduling completed (success: $registrationSucceeded)',
        name: 'Restoreko',
      );

    } catch (e, stackTrace) {
      developer.log(
        '[BackgroundService] Critical error in scheduleDailyNotification: $e',
        name: 'Restoreko',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - app should continue working
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
    if (!_isInitialized) {
      developer.log(
        '[BackgroundService] Cannot cancel notification: WorkManager not initialized',
        name: 'Restoreko',
      );
      return;
    }

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
      // Don't rethrow - app should continue working
    }
  }

  /// Check if background services are working properly
  static Future<bool> isWorkingProperly() async {
    return _isInitialized && !_initializationFailed;
  }

  /// Reset the initialization state (useful for testing or manual retry)
  static void resetInitializationState() {
    _isInitialized = false;
    _initializationFailed = false;
    developer.log(
      '[BackgroundService] Initialization state reset',
      name: 'Restoreko',
    );
  }
}