import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'core/constants/app_constants.dart';
import 'features/location_tracking/data/datasources/location_local_datasource.dart';
import 'features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'features/location_tracking/data/datasources/notification_datasource.dart';
import 'features/location_tracking/data/datasources/workmanager_datasource.dart';
import 'features/location_tracking/data/models/location_record_model.dart';
import 'features/location_tracking/data/repositories/location_repository_impl.dart';
import 'features/location_tracking/domain/usecases/update_location.dart';
import 'features/location_tracking/presentation/screens/dashboard_screen.dart';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

/// Background task callback for WorkManager.
/// MUST be top-level function or static method.
/// Cannot use Riverpod in background isolate - manual dependency injection required.
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('[WorkManager] Background task started: $task');

      // ========================================================================
      // HIVE INITIALIZATION IN BACKGROUND ISOLATE
      // ========================================================================
      await Hive.initFlutter();
      Hive.registerAdapter(LocationRecordModelAdapter());
      final box = await Hive.openBox<LocationRecordModel>(
        AppConstants.locationBoxName,
      );

      // ========================================================================
      // MANUAL DEPENDENCY INJECTION (No Riverpod in isolate)
      // ========================================================================
      final localDataSource = LocationLocalDataSourceImpl(hiveBox: box);
      final remoteDataSource = LocationRemoteDataSourceImpl();
      final notificationDataSource = NotificationDataSourceImpl(
        plugin: FlutterLocalNotificationsPlugin(),
      );
      final workManagerDataSource = WorkManagerDataSourceImpl();

      final repository = LocationRepositoryImpl(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        notificationDataSource: notificationDataSource,
        workManagerDataSource: workManagerDataSource,
      );

      // ========================================================================
      // EXECUTE UPDATE LOCATION USE CASE
      // ========================================================================
      final updateLocation = UpdateLocation(repository: repository);
      final result = await updateLocation();

      result.fold(
        (failure) {
          print('[WorkManager] Background task failed: ${failure.message}');
        },
        (_) {
          print('[WorkManager] Background task completed successfully');
        },
      );

      // ========================================================================
      // RESCHEDULE FOR TESTING (only if interval < 15 minutes)
      // ========================================================================
      // WorkManager's minimum periodic frequency is 15 minutes.
      // For testing with shorter intervals, we use one-off tasks that reschedule themselves.
      if (AppConstants.trackingInterval.inMinutes < 15) {
        print('[WorkManager] Rescheduling next task in ${AppConstants.trackingInterval.inSeconds} seconds');
        await workManagerDataSource.registerPeriodicTask();
      }

      return true;
    } catch (e, stackTrace) {
      print('[WorkManager] Background task error: $e');
      print('[WorkManager] Stack trace: $stackTrace');
      return false;
    }
  });
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(LocationRecordModelAdapter());

  await Hive.openBox<LocationRecordModel>(AppConstants.locationBoxName);

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
  // WORKMANAGER INITIALIZATION
  // ============================================================================
  await Workmanager().initialize(
    workmanagerCallbackDispatcher,
    isInDebugMode: true, // Set to false for release
  );

  print('[Main] WorkManager initialized');

  // ============================================================================
  // RUN APP
  // ============================================================================
  runApp(const ProviderScope(child: MyApp()));
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
