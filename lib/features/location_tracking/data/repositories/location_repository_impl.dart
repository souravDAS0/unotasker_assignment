import 'package:permission_handler/permission_handler.dart';
import 'package:unotasker_assignment/core/utils/date_formatter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/location_record.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';
import '../datasources/location_remote_datasource.dart';
import '../datasources/notification_datasource.dart';
import '../datasources/background_service_datasource.dart';
import '../models/location_record_model.dart';

/// Implementation of LocationRepository that coordinates all data sources.
class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource localDataSource;
  final LocationRemoteDataSource remoteDataSource;
  final NotificationDataSource notificationDataSource;
  final BackgroundServiceDataSource? backgroundServiceDataSource;

  LocationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.notificationDataSource,
    this.backgroundServiceDataSource,
  });

  @override
  Future<bool> requestPermissions() async {
    try {
      // Request location permission
      var locationStatus = await Permission.location.request();

      if (locationStatus.isGranted) {
        // Request background location permission if on Android
        var backgroundStatus = await Permission.locationAlways.request();

        // Also request notification permission for Android 13+
        await Permission.notification.request();

        return backgroundStatus.isGranted || backgroundStatus.isLimited;
      }

      return false;
    } catch (e) {
      throw PermissionException('Failed to request permissions', e);
    }
  }

  @override
  Future<bool> hasPermissions() async {
    return await remoteDataSource.hasPermissions();
  }

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      final position = await remoteDataSource.getCurrentLocation();
      return {'latitude': position.latitude, 'longitude': position.longitude};
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException('Failed to get current location', e);
    }
  }

  @override
  Future<String> geocodeLocation(double latitude, double longitude) async {
    try {
      return await remoteDataSource.geocodeAddress(latitude, longitude);
    } catch (e) {
      // Return fallback address instead of throwing
      return AppConstants.addressUnavailable;
    }
  }

  @override
  Future<void> saveRecord(LocationRecord record) async {
    try {
      final model = LocationRecordModel.fromEntity(record);
      await localDataSource.saveRecord(model);
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to save location record', e);
    }
  }

  @override
  Future<List<LocationRecord>> getAllRecords() async {
    try {
      final models = await localDataSource.getAllRecords();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to fetch location records', e);
    }
  }

  @override
  Future<void> deleteAllRecords() async {
    try {
      await localDataSource.deleteAllRecords();
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to delete location records', e);
    }
  }

  @override
  Future<void> showNotification(LocationRecord record) async {
    try {
      final title =
          '${AppConstants.trackingActiveTitle} - ${DateFormatter.formatTimeOnly(record.timestamp)}';
      final body = _formatNotificationBody(record);
      await notificationDataSource.showNotification(title, body);
    } catch (e) {
      if (e is NotificationException) {
        rethrow;
      }
      throw NotificationException('Failed to show notification', e);
    }
  }

  @override
  Future<void> updateNotification(LocationRecord record) async {
    try {
      final title =
          '${AppConstants.trackingActiveTitle} - ${DateFormatter.formatTimeOnly(record.timestamp)}';
      final body = _formatNotificationBody(record);
      await notificationDataSource.updateNotification(title, body);
    } catch (e) {
      if (e is NotificationException) {
        rethrow;
      }
      throw NotificationException('Failed to update notification', e);
    }
  }

  @override
  Future<void> clearNotification() async {
    try {
      await notificationDataSource.clearNotification();
    } catch (e) {
      if (e is NotificationException) {
        rethrow;
      }
      throw NotificationException('Failed to clear notification', e);
    }
  }

  @override
  Future<void> startBackgroundService() async {
    if (backgroundServiceDataSource == null) {
      throw BackgroundServiceException(
        'Background service data source not available',
        null,
      );
    }
    try {
      await backgroundServiceDataSource!.startPeriodicTracking();
    } catch (e) {
      if (e is BackgroundServiceException) {
        rethrow;
      }
      throw BackgroundServiceException('Failed to start background service', e);
    }
  }

  @override
  Future<void> stopBackgroundService() async {
    if (backgroundServiceDataSource == null) {
      throw BackgroundServiceException(
        'Background service data source not available',
        null,
      );
    }
    try {
      await backgroundServiceDataSource!.stopPeriodicTracking();
    } catch (e) {
      if (e is BackgroundServiceException) {
        rethrow;
      }
      throw BackgroundServiceException('Failed to stop background service', e);
    }
  }

  @override
  Future<bool> checkServiceStatus() async {
    if (backgroundServiceDataSource == null) {
      throw BackgroundServiceException(
        'Background service data source not available',
        null,
      );
    }
    try {
      return await backgroundServiceDataSource!.isServiceRunning();
    } catch (e) {
      if (e is BackgroundServiceException) {
        rethrow;
      }
      throw BackgroundServiceException('Failed to check service status', e);
    }
  }

  /// Formats the notification body with location data.
  String _formatNotificationBody(LocationRecord record) {
    return '${record.address}\nLat: ${record.latitude.toStringAsFixed(6)}, Lng: ${record.longitude.toStringAsFixed(6)}';
  }
}
