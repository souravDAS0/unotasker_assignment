import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/location_record.dart';
import '../../domain/repositories/location_repository.dart';

/// Foreground service that runs periodic location tracking using Dart Timer.
/// This replaces WorkManager which has a 15-minute minimum (too long for 5-min requirement).
class TrackingService {
  final LocationRepository repository;
  Timer? _timer;
  bool _isRunning = false;

  TrackingService({required this.repository});

  /// Starts the tracking service with periodic timer.
  Future<void> start() async {
    if (_isRunning) {
      print('[TrackingService] Already running, ignoring start request');
      return;
    }

    print('[TrackingService] Starting foreground tracking service');
    _isRunning = true;

    // Fetch location immediately (don't wait for first timer)
    await _fetchAndSaveLocation();

    // Set up periodic timer
    // Works for any interval: 30 seconds (testing) or 5 minutes (production)
    _timer = Timer.periodic(
      AppConstants.trackingInterval,
      (timer) async {
        if (!_isRunning) {
          timer.cancel();
          return;
        }
        await _fetchAndSaveLocation();
      },
    );

    print('[TrackingService] Timer scheduled for every ${AppConstants.trackingInterval.inSeconds}s');
  }

  /// Stops the tracking service and cancels the timer.
  void stop() {
    print('[TrackingService] Stopping foreground tracking service');
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Fetches current location, geocodes it, saves to storage, and updates notification.
  Future<void> _fetchAndSaveLocation() async {
    try {
      print('[TrackingService] Fetching location at ${DateTime.now()}');

      // Get current location
      final locationData = await repository.getCurrentLocation();
      final latitude = locationData['latitude']!;
      final longitude = locationData['longitude']!;

      // Geocode to address
      final address = await repository.geocodeLocation(latitude, longitude);

      // Create and save record
      final record = LocationRecord(
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      await repository.saveRecord(record);

      // Update notification with new location
      await repository.updateNotification(record);

      print('[TrackingService] Location saved: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}');
    } catch (e) {
      print('[TrackingService] Error fetching location: $e');
    }
  }

  /// Returns true if the service is currently running.
  bool get isRunning => _isRunning;
}
