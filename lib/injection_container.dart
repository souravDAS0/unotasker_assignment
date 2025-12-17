import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/location_tracking/data/datasources/background_service_datasource.dart';
import 'features/location_tracking/data/datasources/location_local_datasource.dart';
import 'features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'features/location_tracking/data/datasources/notification_datasource.dart';
import 'features/location_tracking/data/repositories/location_repository_impl.dart';
import 'features/location_tracking/domain/repositories/location_repository.dart';
import 'features/location_tracking/domain/usecases/get_location_records.dart';
import 'features/location_tracking/domain/usecases/start_tracking.dart';
import 'features/location_tracking/domain/usecases/stop_tracking.dart';
import 'features/location_tracking/domain/usecases/update_location.dart';
import 'features/location_tracking/domain/usecases/check_tracking_status.dart';
import 'features/location_tracking/presentation/providers/tracking_provider.dart';
import 'features/location_tracking/presentation/state/tracking_state.dart';

// ============================================================================
// DEPENDENCY INJECTION CONTAINER
// ============================================================================
// This file contains all Riverpod providers for dependency injection.
// Dependencies flow: Presentation -> Domain <- Data
// All providers are defined here to maintain single source of truth.
// ============================================================================

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider for local data source (Hive storage).
final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((
  ref,
) {
  return LocationLocalDataSourceImpl();
});

/// Provider for remote data source (Geolocator & Geocoding).
final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((
  ref,
) {
  return LocationRemoteDataSourceImpl();
});

/// Provider for notification data source.
final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  return NotificationDataSourceImpl(plugin: FlutterLocalNotificationsPlugin());
});

/// Provider for BackgroundService data source.
final backgroundServiceDataSourceProvider =
    Provider<BackgroundServiceDataSource>((ref) {
      return BackgroundServiceDataSourceImpl();
    });

/// Provider for location repository implementation.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    localDataSource: ref.watch(locationLocalDataSourceProvider),
    remoteDataSource: ref.watch(locationRemoteDataSourceProvider),
    notificationDataSource: ref.watch(notificationDataSourceProvider),
    backgroundServiceDataSource: ref.watch(backgroundServiceDataSourceProvider),
  );
});

// ============================================================================
// DOMAIN LAYER PROVIDERS
// ============================================================================

/// Provider for StartTracking use case.
final startTrackingUseCaseProvider = Provider<StartTracking>((ref) {
  return StartTracking(repository: ref.watch(locationRepositoryProvider));
});

/// Provider for StopTracking use case.
final stopTrackingUseCaseProvider = Provider<StopTracking>((ref) {
  return StopTracking(repository: ref.watch(locationRepositoryProvider));
});

/// Provider for GetLocationRecords use case.
final getLocationRecordsUseCaseProvider = Provider<GetLocationRecords>((ref) {
  return GetLocationRecords(repository: ref.watch(locationRepositoryProvider));
});

/// Provider for UpdateLocation use case (used in background tasks).
final updateLocationUseCaseProvider = Provider<UpdateLocation>((ref) {
  return UpdateLocation(repository: ref.watch(locationRepositoryProvider));
});

/// Provider for CheckTrackingStatus use case.
final checkTrackingStatusUseCaseProvider = Provider<CheckTrackingStatus>((ref) {
  return CheckTrackingStatus(repository: ref.watch(locationRepositoryProvider));
});

// ============================================================================
// PRESENTATION LAYER PROVIDERS
// ============================================================================

/// Provider for tracking state management.
/// This is the main StateNotifier that manages the UI state.
final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>(
  (ref) {
    return TrackingNotifier(
      startTracking: ref.watch(startTrackingUseCaseProvider),
      stopTracking: ref.watch(stopTrackingUseCaseProvider),
      getLocationRecords: ref.watch(getLocationRecordsUseCaseProvider),
      checkTrackingStatus: ref.watch(checkTrackingStatusUseCaseProvider),
      localDataSource: ref.watch(locationLocalDataSourceProvider),
    );
  },
);
