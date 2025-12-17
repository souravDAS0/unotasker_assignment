import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_location_records.dart';
import '../../domain/usecases/start_tracking.dart';
import '../../domain/usecases/stop_tracking.dart';
import '../state/tracking_state.dart';

/// StateNotifier for managing tracking state and actions.
/// Handles starting/stopping tracking and loading location records.
class TrackingNotifier extends StateNotifier<TrackingState> {
  final StartTracking startTracking;
  final StopTracking stopTracking;
  final GetLocationRecords getLocationRecords;

  TrackingNotifier({
    required this.startTracking,
    required this.stopTracking,
    required this.getLocationRecords,
  }) : super(TrackingState.initial()) {
    // Load records on initialization
    loadRecords();
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
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        // Handle success
        state = state.copyWith(
          isTracking: true,
          isLoading: false,
        );
        // Reload records to show the first location
        loadRecords();
      },
    );
  }

  /// Stops location tracking.
  /// Stops background service, deletes all records, and clears notification.
  Future<void> stopTrackingAction() async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    // Execute stop tracking use case
    final result = await stopTracking();

    result.fold(
      (failure) {
        // Handle failure
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
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

  /// Clears the current error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
