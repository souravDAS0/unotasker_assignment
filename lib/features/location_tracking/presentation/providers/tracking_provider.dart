import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../../data/datasources/location_local_datasource.dart';
import '../../domain/usecases/get_location_records.dart';
import '../../domain/usecases/start_tracking.dart';
import '../../domain/usecases/stop_tracking.dart';
import '../../domain/usecases/check_tracking_status.dart';
import '../state/tracking_state.dart';

class TrackingNotifier extends StateNotifier<TrackingState> {
  final StartTracking startTracking;
  final StopTracking stopTracking;
  final GetLocationRecords getLocationRecords;
  final CheckTrackingStatus checkTrackingStatus;
  final LocationLocalDataSource localDataSource;

  // Stream subscription for background service messages
  StreamSubscription? _serviceListener;

  // Fallback timer in case messages are missed
  Timer? _fallbackTimer;

  TrackingNotifier({
    required this.startTracking,
    required this.stopTracking,
    required this.getLocationRecords,
    required this.checkTrackingStatus,
    required this.localDataSource,
  }) : super(TrackingState.initial()) {
    // Initialize: check actual service status and load records
    _initializeState();
  }

  @override
  void dispose() {
    _serviceListener?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  /// Initializes state by checking actual service status and loading records.
  /// This ensures UI state syncs with the background service after app restart.
  Future<void> _initializeState() async {
    // First check if service is actually running
    final statusResult = await checkTrackingStatus();

    statusResult.fold(
      (failure) {
        // If we can't check status, just proceed with default state
        print(
          '[TrackingNotifier] Failed to check service status: ${failure.message}',
        );
      },
      (isRunning) {
        // Sync UI state with actual service status
        if (isRunning) {
          state = state.copyWith(isTracking: true);
          // Start listening for service messages if service is running
          _startServiceListener();
          print('[TrackingNotifier] Service is running - UI state synced');
        }
      },
    );

    // Load existing records
    await loadRecords();
  }

  /// Starts location tracking.
  /// Requests permissions, fetches location, saves it, shows notification, and starts background service.
  Future<void> startTrackingAction() async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    // Execute start tracking use case
    final result = await startTracking();

    result.fold(
      (failure) {
        // Handle failure
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        // Handle success
        state = state.copyWith(isTracking: true, isLoading: false);
        // Reload records to show the first location
        loadRecords();

        // Start service message listener for real-time updates
        _startServiceListener();
      },
    );
  }

  /// Stops location tracking.
  /// Stops background service, deletes all records, and clears notification.
  Future<void> stopTrackingAction() async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    // Stop service listener and fallback timer
    _stopServiceListener();

    // Execute stop tracking use case
    final result = await stopTracking();

    result.fold(
      (failure) {
        // Handle failure
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        // Handle success - clear all data
        state = state.copyWith(
          isTracking: false,
          records: [],
          isLoading: false,
        );
      },
    );
  }

  /// Loads all location records from storage.
  /// Called after starting tracking and on initialization.
  Future<void> loadRecords() async {
    final result = await getLocationRecords();

    result.fold(
      (failure) {
        // Handle failure - keep existing records, show error
        state = state.copyWith(errorMessage: failure.message);
      },
      (records) {
        // Handle success - update records
        state = state.copyWith(records: records, clearError: true);
      },
    );
  }

  /// Starts listening to background service messages for real-time updates.
  /// Also starts a fallback timer in case messages are missed.
  void _startServiceListener() {
    _serviceListener?.cancel(); // Cancel any existing listener
    _fallbackTimer?.cancel(); // Cancel any existing timer

    try {
      final service = FlutterBackgroundService();

      // Listen for 'record_saved' messages from background service
      _serviceListener = service.on('record_saved').listen((event) async {
        print(
          '[TrackingNotifier] Received record_saved event from background service',
        );
        if (state.isTracking) {
          // Force Hive to reload from disk by closing and reopening box
          await localDataSource.refreshBox();
          // Now load records - should get fresh data from disk
          loadRecords();
        }
      });

      print(
        '[TrackingNotifier] Service message listener and fallback timer started',
      );
    } catch (e) {
      print('[TrackingNotifier] Failed to start service listener: $e');
    }
  }

  /// Stops the service message listener and fallback timer.
  void _stopServiceListener() {
    _serviceListener?.cancel();
    _serviceListener = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    print('[TrackingNotifier] Service listener and fallback timer stopped');
  }

  /// Clears the current error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
