import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'features/location_tracking/data/datasources/location_local_datasource.dart';
import 'features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'features/location_tracking/data/datasources/notification_datasource.dart';
import 'features/location_tracking/data/datasources/workmanager_datasource.dart';
import 'features/location_tracking/data/models/location_record_model.dart';
import 'features/location_tracking/data/repositories/location_repository_impl.dart';
import 'features/location_tracking/domain/repositories/location_repository.dart';
import 'features/location_tracking/domain/usecases/get_location_records.dart';
import 'features/location_tracking/domain/usecases/start_tracking.dart';
import 'features/location_tracking/domain/usecases/stop_tracking.dart';
import 'features/location_tracking/domain/usecases/update_location.dart';
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
// CORE PROVIDERS
// ============================================================================

/// Provider for Hive box containing location records.
/// This provider will be overridden in main.dart after Hive initialization.
final hiveBoxProvider = Provider<Box<LocationRecordModel>>((ref) {
  return Hive.box<LocationRecordModel>(AppConstants.locationBoxName);
});

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider for local data source (Hive storage).
final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((ref) {
  return LocationLocalDataSourceImpl(hiveBox: ref.watch(hiveBoxProvider));
});

/// Provider for remote data source (Geolocator & Geocoding).
final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((ref) {
  return LocationRemoteDataSourceImpl();
});

/// Provider for notification data source.
final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  return NotificationDataSourceImpl(plugin: FlutterLocalNotificationsPlugin());
});

/// Provider for WorkManager data source.
final workManagerDataSourceProvider = Provider<WorkManagerDataSource>((ref) {
  return WorkManagerDataSourceImpl();
});

/// Provider for location repository implementation.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    localDataSource: ref.watch(locationLocalDataSourceProvider),
    remoteDataSource: ref.watch(locationRemoteDataSourceProvider),
    notificationDataSource: ref.watch(notificationDataSourceProvider),
    workManagerDataSource: ref.watch(workManagerDataSourceProvider),
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

// ============================================================================
// PRESENTATION LAYER PROVIDERS
// ============================================================================

/// Provider for tracking state management.
/// This is the main StateNotifier that manages the UI state.
final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(
    startTracking: ref.watch(startTrackingUseCaseProvider),
    stopTracking: ref.watch(stopTrackingUseCaseProvider),
    getLocationRecords: ref.watch(getLocationRecordsUseCaseProvider),
  );
});
