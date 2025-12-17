class AppConstants {
  AppConstants._();

  // Tracking Configuration
  // static const Duration trackingInterval = Duration(minutes: 5);
  static const Duration trackingInterval = Duration(seconds: 30);

  // Notification Configuration
  static const int notificationId = 1000;
  static const String notificationChannelId = 'location_tracking_channel';
  static const String notificationChannelName = 'Location Tracking';
  static const String notificationChannelDescription =
      'Persistent location tracking notifications';

  // Hive Configuration
  static const String locationBoxName = 'location_records';
  static const int locationRecordTypeId = 0;

  // WorkManager Configuration
  static const String trackingTaskName = 'location_tracking_task';

  // UI Messages
  static const String trackingActiveTitle = 'Location Tracking Active';
  static const String addressUnavailable = 'Address unavailable';

  // Error Messages
  static const String permissionDeniedMessage =
      'Location permission denied. Please enable location access in settings.';
  static const String locationServiceDisabledMessage =
      'Location services are disabled. Please enable them in settings.';
  static const String locationFetchErrorMessage =
      'Failed to fetch location. Please try again.';
  static const String storageErrorMessage =
      'Failed to save location data. Please try again.';
  static const String notificationErrorMessage =
      'Failed to show notification. Please check notification permissions.';
}
