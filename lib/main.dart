import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

/// Background task callback for WorkManager
/// MUST be top-level function or static method
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO: Initialize Hive in isolate
    // TODO: Call UpdateLocation use case
    // TODO: Handle errors gracefully

    print('[WorkManager] Background task executed: $task');
    return Future.value(true);
  });
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================================
  // HIVE INITIALIZATION
  // ============================================================================
  await Hive.initFlutter();

  // TODO: Register Hive TypeAdapters here
  // Example: Hive.registerAdapter(LocationRecordModelAdapter());

  // TODO: Open Hive box
  // final box = await Hive.openBox('location_records');

  // ============================================================================
  // WORKMANAGER INITIALIZATION
  // ============================================================================
  await Workmanager().initialize(
    workmanagerCallbackDispatcher,
    isInDebugMode: true, // Set to false for release
  );

  // ============================================================================
  // RUN APP
  // ============================================================================
  runApp(
    const ProviderScope(
      // TODO: Override hiveBoxProvider here when box is opened
      child: MyApp(),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // TODO: Replace with DashboardScreen when implemented
      home: const PlaceholderScreen(),
    );
  }
}

// ============================================================================
// TEMPORARY PLACEHOLDER SCREEN
// ============================================================================

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Location Tracking App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Setup Complete - Ready for Implementation',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
