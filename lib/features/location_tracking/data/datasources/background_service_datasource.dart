import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../../../core/errors/exceptions.dart';

/// Abstract interface for background service operations.
abstract class BackgroundServiceDataSource {
  /// Starts periodic location tracking.
  Future<void> startPeriodicTracking();

  /// Stops periodic location tracking.
  Future<void> stopPeriodicTracking();

  /// Checks if the background service is currently running.
  Future<bool> isServiceRunning();
}

/// Implementation of BackgroundServiceDataSource using flutter_background_service.
class BackgroundServiceDataSourceImpl implements BackgroundServiceDataSource {
  final FlutterBackgroundService _service = FlutterBackgroundService();

  @override
  Future<void> startPeriodicTracking() async {
    try {
      final isRunning = await _service.isRunning();
      if (isRunning) {
        print('[BackgroundService] Service already running');
        return;
      }

      await _service.startService();
      print('[BackgroundService] Service started');
    } catch (e) {
      throw BackgroundServiceException('Failed to start tracking', e);
    }
  }

  @override
  Future<void> stopPeriodicTracking() async {
    try {
      final isRunning = await _service.isRunning();
      if (!isRunning) {
        print('[BackgroundService] Service not running');
        return;
      }

      _service.invoke('stopService');
      print('[BackgroundService] Stop command sent');
    } catch (e) {
      throw BackgroundServiceException('Failed to stop tracking', e);
    }
  }

  @override
  Future<bool> isServiceRunning() async {
    try {
      return await _service.isRunning();
    } catch (e) {
      throw BackgroundServiceException('Failed to check service status', e);
    }
  }
}

/// Background service entry point for iOS.
/// Must be a top-level function.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// Background service entry point.
/// This function will be called when the service starts.
/// Must be a top-level function.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only for Android: ensure the plugin is initialized
  DartPluginRegistrant.ensureInitialized();

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
    service.stopSelf();
  });

  // Note: The actual location tracking logic will be injected here from main.dart
  // This is just a placeholder that shows the service is running
  print('[BackgroundService] Service entry point called');
}
