import 'dart:async';

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
