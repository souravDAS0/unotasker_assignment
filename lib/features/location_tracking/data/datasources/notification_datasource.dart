import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Abstract interface for notification operations.
abstract class NotificationDataSource {
  /// Initializes the notification plugin with platform-specific settings.
  Future<void> initialize();

  /// Shows a persistent notification with the given title and body.
  Future<void> showNotification(String title, String body);

  /// Updates the existing notification with new content.
  Future<void> updateNotification(String title, String body);

  /// Clears the persistent notification.
  Future<void> clearNotification();
}

/// Implementation of NotificationDataSource using flutter_local_notifications.
class NotificationDataSourceImpl implements NotificationDataSource {
  final FlutterLocalNotificationsPlugin plugin;

  NotificationDataSourceImpl({required this.plugin});

  @override
  Future<void> initialize() async {
    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create Android notification channel (HIGH priority for foreground service)
      const androidChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
      );

      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // Request permissions for Android 13+
      await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      throw NotificationException('Failed to initialize notifications', e);
    }
  }

  @override
  Future<void> showNotification(String title, String body) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true, // Non-dismissible
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        // Foreground service notification
        category: AndroidNotificationCategory.service,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await plugin.show(
        AppConstants.notificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      throw NotificationException('Failed to show notification', e);
    }
  }

  @override
  Future<void> updateNotification(String title, String body) async {
    // Update uses the same ID, so it replaces the existing notification
    await showNotification(title, body);
  }

  @override
  Future<void> clearNotification() async {
    try {
      await plugin.cancel(AppConstants.notificationId);
    } catch (e) {
      throw NotificationException('Failed to clear notification', e);
    }
  }

  /// Handles notification tap events.
  /// Can be extended to handle stop tracking from notification action.
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // For now, this just logs the tap
    // In the future, can add "Stop Tracking" action button handling
  }
}
