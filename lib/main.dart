import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'features/location_tracking/data/datasources/location_local_datasource.dart';
import 'features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'features/location_tracking/data/datasources/notification_datasource.dart';
import 'features/location_tracking/data/repositories/location_repository_impl.dart';
import 'features/location_tracking/domain/usecases/update_location.dart';
import 'features/location_tracking/presentation/screens/dashboard_screen.dart';

// ============================================================================
// BACKGROUND SERVICE ENTRY POINT
// ============================================================================

/// Background service callback for flutter_background_service.
/// MUST be top-level function or static method.
/// Cannot use Riverpod in background isolate - manual dependency injection required.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only for Android: ensure the plugin is initialized
  DartPluginRegistrant.ensureInitialized();

  // For Android: Set up foreground service
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Listen for stop service command
  service.on('stopService').listen((event) {
    print('[BackgroundService] Stop command received');
    service.stopSelf();
  });

  print('[BackgroundService] Service started');

  // ========================================================================
  // HIVE INITIALIZATION IN BACKGROUND ISOLATE
  // ========================================================================
  await Hive.initFlutter();
  // Use string-based box for JSON storage (better cross-isolate compatibility)
  await Hive.openBox<String>(AppConstants.locationBoxName);
  print('[BackgroundService] Hive box opened successfully');
  // ========================================================================
  // MANUAL DEPENDENCY INJECTION (No Riverpod in isolate)
  // ========================================================================
  final localDataSource = LocationLocalDataSourceImpl();
  final remoteDataSource = LocationRemoteDataSourceImpl();
  final notificationDataSource = NotificationDataSourceImpl(
    plugin: FlutterLocalNotificationsPlugin(),
    skipPermissions: true, // Skip permission requests in background isolate
  );

  // Initialize notification plugin
  try {
    await notificationDataSource.initialize();
    print('[BackgroundService] Notifications initialized');
  } catch (e) {
    print('[BackgroundService] Notification initialization failed: $e');
  }

  final repository = LocationRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    notificationDataSource: notificationDataSource,
  );

  final updateLocation = UpdateLocation(repository: repository);

  // ========================================================================
  // PERIODIC TIMER FOR LOCATION TRACKING
  // ========================================================================
  Timer.periodic(AppConstants.trackingInterval, (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print(
          '[BackgroundService] Timer tick - Interval: ${AppConstants.trackingInterval.inSeconds}s',
        );

        // Execute location update
        final result = await updateLocation();

        result.fold(
          (failure) {
            print(
              '[BackgroundService] Location update failed: ${failure.message}',
            );
          },
          (locationRecord) {
            print('[BackgroundService] Location update completed successfully');

            // Notify main isolate that a new record was saved
            service.invoke('record_saved');
          },
        );

        service.setForegroundNotificationInfo(
          title: AppConstants.trackingActiveTitle,
          content: AppConstants.trackingActiveBody,
        );
      } else {
        // Service is not in foreground mode anymore, stop the timer
        timer.cancel();
        service.stopSelf();
      }
    } else {
      // iOS or service status check
      print(
        '[BackgroundService] Timer tick - Interval: ${AppConstants.trackingInterval.inSeconds}s',
      );

      // Execute location update
      final result = await updateLocation();

      result.fold(
        (failure) {
          print(
            '[BackgroundService] Location update failed: ${failure.message}',
          );
        },
        (locationRecord) {
          print('[BackgroundService] Location update completed successfully');
          print(
            '[BackgroundService] Location: ${locationRecord.address} at ${locationRecord.timestamp}',
          );
          // Notify main isolate that a new record was saved
          service.invoke('record_saved');
        },
      );
    }
  });

  print(
    '[BackgroundService] Periodic timer started with ${AppConstants.trackingInterval.inSeconds}s interval',
  );
}

/// iOS background entry point.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================================
  // HIVE INITIALIZATION (Main Isolate)
  // ============================================================================
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.locationBoxName);

  // ============================================================================
  // NOTIFICATION INITIALIZATION (Main Isolate)
  // ============================================================================
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  final notificationDataSource = NotificationDataSourceImpl(
    plugin: notificationPlugin,
  );

  try {
    await notificationDataSource.initialize();
    print('[Main] Notifications initialized successfully');
  } catch (e) {
    print('[Main] Notification initialization failed: $e');
  }

  // ============================================================================
  // CREATE BACKGROUND SERVICE NOTIFICATION CHANNEL
  // ============================================================================
  // CRITICAL: This channel MUST be created before starting the background service
  // Otherwise, the foreground service will crash with CannotPostForegroundServiceNotificationException
  try {
    final androidPlugin = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const serviceChannel = AndroidNotificationChannel(
        AppConstants.notificationServiceChannelId,
        AppConstants.notificationServiceChannelName,
        description: AppConstants.notificationServiceChannelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      );

      await androidPlugin.createNotificationChannel(serviceChannel);
      print('[Main] Background service notification channel created');
    }
  } catch (e) {
    print('[Main] Failed to create service notification channel: $e');
  }

  // ============================================================================
  // BACKGROUND SERVICE INITIALIZATION
  // ============================================================================
  await initializeBackgroundService();

  print('[Main] Background service initialized');

  // ============================================================================
  // RUN APP
  // ============================================================================
  runApp(const ProviderScope(child: MyApp()));
}

/// Initializes the flutter_background_service.
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      notificationChannelId: AppConstants.notificationServiceChannelId,
      initialNotificationTitle: AppConstants.trackingActiveTitle,
      initialNotificationContent: AppConstants.trackingActiveBody,
      // foregroundServiceTypes: [AndroidForegroundType.location],
    ),
  );
}

// ============================================================================
// ROOT APP WIDGET
// ============================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 42, 0, 104),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      home: const DashboardScreen(),
    );
  }
}
